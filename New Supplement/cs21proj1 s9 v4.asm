# CS 21 LAB4 -- S2 AY 2021-2022
# Yenzy Urson S. Hebron -- 04/18/2022
# 202003090_9.asm -- 9x9 Sudoku Solver
# New: grid and raw now stored in main stack frame, more faithful to translated C program
# Notes: getGrid is now implemented arithmetically to better handle 9 digit inputs.

.include "macros.asm"

.text
# main stores grid just above $sp, and raw just above grid.
main:
	# TODO: store grid in main stackframe to mimic typical C programs (driver code at main)
	addi	$sp, $sp, -512
	sw	$ra, 508($sp)
	sw	$s0, 0($sp)
	
	addi	$s0, $sp, 0	# s0 = (int) grid[81] = {0}, 1D array with 16 integer elements
	move	$t0, $s0	# use t0 to run through grid and initialize all elements to 0, paranoid hehe
	addi	$t1, $s0, 324	# &(grid[80]) (last element of grid)
init:	
	beq	$t0, $t1, initdone
	sw	$0, 0($t0)	# insert 0
	addi	$t0, $t0, 4	# next word
	j	init
initdone:
	
	# fill-up grid using getGrid(grid)
	move	$a0, $s0
	jal	getGrid
	
	# solve puzzle
	move	$a0, $s0	# init solver as sudoku(grid, 0)
	li	$a1, 0
	jal	sudoku
	
	# print solved puzzle
	move	$a0, $s0
	jal	printGrid
	
	lw	$s0, 0($sp)
	lw	$ra, 508($sp)
	addi	$sp, $sp, 512
	exit()
	
# getGrid(a0 = grid, a1 = raw)
getGrid:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	
	# use (int) raw as "input buffer"
	
	move	$s0, $a0	# s0 = grid
	li	$t0, 0		# t0 = i = 0
for1:
	beq	$t0, 9, end1
	read_int_to($s1)	# s1 = raw
	li	$t1, 8		# t1 = j = 3
for2:	
	beq	$t1, -1, end2
	rem	$t2, $s1, 10	# t2 = num
	li	$t3, 9		# i * 9
	mult	$t0, $t3
	mflo	$t3
	add	$t3, $t1, $t3	# j + (i * 9)
	sll	$t3, $t3, 2	# byte offset
	add	$t3, $s0, $t3	# t3 = (grid + j + (i * 9))
	sw	$t2, 0($t3)	# grid[j + (i * 9)] = num
	div	$s1, $s1, 10	# raw = raw // 10
	
	subi	$t1, $t1, 1	# j--
	j	for2
end2:	
	addi	$t0, $t0, 1	# i++
	j	for1
end1:
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra
	
# sudoku(a0 = grid, a1 = pos)
sudoku:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s3, 12($sp)
	sw	$s4, 8($sp)
	sw	$s5, 4($sp)
	
	# immediately check base case
	bne	$a1, 81, notbase	
	li	$v0, 1		# return 1 on base case
	jr	$ra
	
notbase:
	move	$s0, $a0	# s0 = grid
	move	$s1, $a1	# s1 = pos
	
	# compute row and col

	div	$s2, $s1, 9	# s2 = row = pos//9
	li	$t0, 9		# row * 9
	mult	$s2, $t0
	mflo	$t0		# t0 = row * 9
	sub	$s3, $s1, $t0	# s3 = col = pos - row * 9
	
	sll	$t0, $s1, 2	# "pos * 4" (convert to word offset) <MIPS>
	add	$s4, $s0, $t0	# (grid + pos) <C>
	lw	$t0, 0($s4)	# t0 = *(grid + pos) <C>
	bnez	$t0, notempty
	
	# test values
	li	$s5, 1		# s5 = test value (aka test)
testval:
	bgt	$s5, 9, fail	# exhaust test values (1 to 9)
	
	move	$a0, $s0	# a0 = grid
	move	$a1, $s2	# a1 = row
	move	$a2, $s3	# a2 = col
	move	$a3, $s5	# a3 = test
	jal	BoxCheck	# check if Box is safe
	beqz	$v0, unsafe
	jal	RowColCheck	# check if Row Col is safe
	beqz	$v0, unsafe
	
	sw	$s5, 0($s4)	# *(grid + pos) = i (insert test val)
	
	move	$a0, $s0	# a0 = grid
	addi	$t1, $s1, 1	# t1 = pos + 1
	move	$a1, $t1	# a1 = pos + 1
	jal	sudoku
	beqz	$v0, backtrack	# go to backtrack
	li	$v0, 1
	j	return1		# valid state </>

backtrack:
	sw	$0, 0($s4)	# undo insertion
unsafe:
	addi	$s5, $s5, 1	# test++ (increment test value)
	j	testval		# loop back

notempty:			# elif (sudoku(grid, pos + 1)), check state of next pos
	move	$a0, $s0	# a0 = grid
	addi	$t1, $s1, 1	# t1 = pos + 1
	move	$a1, $t1	# a1 = pos + 1
	jal	sudoku
	beqz	$v0, fail
	li	$v0, 1		# valid state </>
	j	return1
fail:
	li	$v0, 0		# invalid state <X>

return1:
	lw	$s5, 4($sp)
	lw	$s4, 8($sp)
	lw	$s3, 12($sp)
	lw	$s2, 16($sp)
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra
	
# RowColCheck(a0 = grid, a1 = row, a2 = col, a3 = test)
RowColCheck:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	
	move	$s0, $a0	# grid
	
	li	$t0, 0		# j = 0
	li	$t1, 9
	mult	$a1, $t1	# lo = row * 9 (largest is 8*9 = 72)
	mflo	$s1		# rowpos = row * 9
rowchk:
	beq	$t0, 9, rowchkperfect	# beq instead of bge
	add	$t1, $s1, $t0	# rowpos + j
	sll	$t1, $t1, 2	# "(rowpos + j) * 4" <pointer arithmetic>
	add	$t1, $s0, $t1	# grid + rowpos + j
	lw	$t2, 0($t1)	# *(grid + rowpos + j)
	bne	$t2, $a3, rowgood	# elif test dupe in row exist, row fail
	li	$v0, 0		# return 0
	j	RCret
rowgood:
	addi	$t0, $t0, 1	# j++ (go to next row entry)
	j	rowchk
rowchkperfect:

	move	$t0, $a2	# j = col
colchk:
	bge	$t0, 81, colchkperfect
	sll	$t1, $t0, 2	# "j * 4" <pointer arithmetic>
	add	$t1, $s0, $t1	# grid + j
	lw	$t2, 0($t1)	# *(grid + j)
	bne	$t2, $a3, colgood	# elif test dupe in col exist, col fail
	li	$v0, 0		# return 0
	j	RCret		# fail
colgood:
	addi	$t0, $t0, 9	# j += 4 (go to next col entry)
	j	colchk
colchkperfect:

	li	$v0, 1		# return 1

RCret:
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra
	
# BoxCheck(a0 = grid, a1 = row, a2 = col, a3 = test)
BoxCheck:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	
	# determine first square of box, set to s0 = j
	bge	$a1, 6, next1
	bge	$a1, 3, next2
	bge	$a2, 6, next3
	bge	$a2, 3, next4
	li	$s0, 0
	j	jdone
next4:	li	$s0, 3
	j	jdone
next3:	li	$s0, 6
	j	jdone
next2:	bge	$a2, 6, next5
	bge	$a2, 3, next6
	li	$s0, 27
	j	jdone
next6:	li	$s0, 30
	j	jdone
next5:	li	$s0, 33
	j	jdone
next1:	bge	$a2, 6, next7
	bge	$a2, 3, next8
	li	$s0, 54
	j	jdone
next8:	li	$s0, 57
	j	jdone
next7:	li	$s0, 60
	j	jdone
	
jdone:	# note that $s0 = j
	addi	$s1, $s0, 2	# k = j + 1
boxchk:	
	bgt	$s0, $s1, boxgood
	sll	$t0, $s0, 2	# "j * 4" <pointer arithmetic>
	add	$t0, $a0, $t0	# grid + j
	lw	$t1, 0($t0)	# *(grid + j)
	beq	$t1, $a3, boxfail	# de Morgan's modification

	addi	$t0, $s0, 9	# j + 9
	sll	$t0, $t0, 2	# "(j + 9) * 4"
	add	$t0, $a0, $t0	# grid + j + 9
	lw	$t1, 0($t0)	# *(grid + j + 9)
	beq	$t1, $a3, boxfail
	
	addi	$t0, $s0, 18	# j + 18
	sll	$t0, $t0, 2	# "(j + 18) * 4"
	add	$t0, $a0, $t0	# grid + j + 9
	lw	$t1, 0($t0)	# *(grid + j + 9)
	beq	$t1, $a3, boxfail

	addi	$s0, $s0, 1	# j++
	j	boxchk

boxfail:
	li	$v0, 0		# return 0
	j	boxret
boxgood:
	li	$v0, 1		# return 1 when all checks passed
boxret:
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra

#printGrid(a0 = grid)
printGrid:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	
	move	$s0, $a0	# s0 = grid
	li	$s1, 0		# i = 0
printer:
	beq	$s1, 81, printerdone
	rem	$t0, $s1, 9
	bnez	$t0, nonewline
	print_val('\n', 11)
nonewline:
	sll	$t1, $s1, 2	# convert to byte offset
	add	$t1, $s0, $t1	# (grid + i)
	lw	$t1, 0($t1)	# *(grid + i)
	print_val($t1, 1)	# print grid[i]
	addi	$s1, $s1, 1
	j	printer
printerdone:
	
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra
	
#.data	
#grid:	.space	64
#raw:	.space	12
