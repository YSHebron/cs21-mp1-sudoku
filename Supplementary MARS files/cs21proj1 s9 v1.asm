# CS 21 LAB4 -- S2 AY 2021-2022
# Yenzy Urson S. Hebron -- 04/18/2022
# 202003090_4.asm -- 4x4 Sudoku Solver

.include "macros.asm"

.text
main:
	# TODO: store grid in main stackframe to mimic typical C programs (driver code at main) 
	# fill-up grid using getGrid(grid)
	la	$a0, grid
	jal	getGrid
	
	# solve puzzle
	la	$a0, grid
	li	$a1, 0
	jal	sudoku
	
	# print solved puzzle
	
	exit()
	
# getGrid(a0 = grid)
getGrid:
	addi	$sp, $sp, 32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	
	# use raw (12 bytes allocated) as "input buffer"
	
	move	$s0, $a0	# s0 = grid
	
	li	$s1, 0		# i = 0
for2:	
	beq	$t2, 4, end2	# i == 4
	read_str(raw, 12)	# read input string (row) to raw
	
	li	$t0, 0
for1:	
	beq	$t0, 4, end1
	lb	$s2, raw
	subi	$s2, $s2, 48
	sw	$s2, 0($s0)
	addi	$s0, $s0, 4
	
	lw	$t1, raw
	srl	$t1, $t1, 8
	sw	$t1, raw
	
	addi	$t0, $t0, 1
	j	for1
end1:	
	addi	$t2, $t2, 1
	j	for2
end2:
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
	
	bne	$a1, 16, notbase	# immediately check base case
	li	$v0, 1		# return 1 on base case
	jr	$ra
	
notbase:
	move	$s0, $a0	# s0 = grid
	move	$s1, $a1	# s1 = pos
	
	srl	$s2, $s1, 2	# s2 = row = pos//4
	sll	$t0, $s2, 2	# t0 = row * 4
	sub	$s3, $s1, $t0	# s3 = col = pos - row * 4
	
	sll	$t0, $s1, 2	# "pos * 4" (convert to word increment) <MIPS>
	add	$s4, $s0, $t0	# (grid + pos) <C>
	lw	$t0, 0($s4)	# t0 = *(grid + pos) <C>
	bnez	$t0, notempty
	
	li	$s5, 1		# s5 = test value (aka test)
testval:
	bgt	$s5, 4, fail	# exhaust test values (1 to 4)
	
	move	$a0, $s0	# a0 = grid
	move	$a1, $s2	# a1 = row
	move	$a2, $s3	# a2 = col
	move	$a3, $s5	# a3 = test
	jal	RowColCheck	# check if Row Col is safe
	beqz	$v0, unsafe
	jal	BoxCheck	# check if Box is safe
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
	sll	$s1, $a1, 2 	# rowpos = row * 4
rowchk:
	bge	$t0, 4, rowchkperfect
	add	$t1, $s1, $t0	# rowpos + j
	sll	$t1, $t1, 2	# "(rowpos + j) * 4" <pointer arithmetic>
	add	$t1, $s0, $t1	# grid + rowpos + j
	lw	$t2, 0($t1)	# *(grid + rowpos + j)
	bne	$t2, $a3, rowgood	# elif test dupe in row exist, row fail
	li	$v0, 0		# return 0
	j	rcret
rowgood:
	addi	$t0, $t0, 1	# j++ (go to next row entry)
	j	rowchk
rowchkperfect:

	move	$t0, $a2	# j = col
colchk:
	bge	$t0, 16, colchkperfect
	sll	$t1, $t0, 2	# "j * 4" <pointer arithmetic>
	add	$t1, $s0, $t1	# grid + j
	lw	$t2, 0($t1)	# *(grid + j)
	bne	$t2, $a3, colgood	# elif test dupe in col exist, col fail
	li	$v0, 0		# return 0
	j	rcret		# fail
colgood:
	addi	$t0, $t0, 4	# j += 4 (go to next col entry)
	j	colchk
colchkperfect:

	li	$v0, 1		# return 1

rcret:
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
	bgt	$a1, 1, next1
	bgt	$a2, 1, next1
	li	$s0, 0
	j	jdone
	
next1:	bgt	$a1, 1, next2
	li	$s0, 2
	j	jdone
	
next2:	blt	$a1, 2, next3
	bgt	$a2, 1, next3
	li	$s0, 8
	j	jdone
	
next3:	li	$s0, 10
	
	# s0 = j determined
jdone:
	addi	$s1, $s0, 1	# k = j + 1
boxchk:	
	bgt	$s0, $s1, boxchkperfect
	sll	$t0, $s0, 2	# "j * 4" <pointer arithmetic>
	add	$t0, $a0, $t0	# grid + j
	lw	$t1, 0($t0)	# *(grid + j)
	seq	$t1, $t1, $a3	# grid[j] == test
	
	addi	$t0, $s0, 4	# j + 4
	sll	$t0, $t0, 2	# "(j + 4) * 4" <pointer arithmetic>
	add	$t0, $a0, $t0	# grid + j + 4
	lw	$t2, 0($t0)	# *(grid + j + 4)
	seq	$t2, $t2, $a3	# grid[j + 4] == test
	
	or	$t0, $t1, $t2	# (grid[j] == test || grid[j + 4] == test)
	beqz	$t0, boxgood
	li	$v0, 0		# return 0
	j	boxret		# fail
boxgood:
	addi	$s0, $s0, 1	# j++
	j	boxchk

boxchkperfect:
	li	$v0, 1		# return 1

boxret:
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra
	
.data	
grid:	.space	324
raw:	.space	12