# CS 21 LAB4 -- S2 AY 2021-2022
# Yenzy Urson S. Hebron -- 04/18/2022
# 202003090_9.asm -- 9x9 Sudoku Solver
# grid is now global

.include "macros.asm"

.text
main:
	# fill-up grid using getGrid()
	la	$a0, grid
	jal	getGrid
	
	# solve puzzle
	la	$a0, grid
	li	$a1, 0
	jal	sudoku
	
	# print solved puzzle
	la	$a0, grid
	jal	printGrid
	
	exit()
	
# getGrid(a0 = grid)
getGrid:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	
	move	$s0, $a0
	# use (int) raw as "input buffer"
	li	$t0, 0		# i = 0
for1:	
	beq	$t0, 81, end1	# i < 81
	read_int_to($s1)	# raw
	li	$t1, 8		# j = 8
for2:	
	beq	$t1, -1, end2	# j != -1
	rem	$t2, $s1, 10	# raw % 10
	add	$t3, $t0, $t1	# (i + j)
	sll	$t3, $t3, 2	# (i + j) << 2
	add	$t4, $s0, $t3	# grid + i + j
	sw	$t2, 0($t4)	# grid[i + j] = num
	div	$s1, $s1, 10	# raw // 10
	addi	$t1, $t1, -1	# j--
	j	for2	
end2:	
	addi	$t0, $t0, 9	# i += 9
	j	for1
end1:
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra
	
# sudoku(a0 = grid, a1 = pos = i)
sudoku:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s3, 12($sp)
	sw	$s4, 8($sp)
	sw	$s5, 4($sp)
	
	bne	$a1, 81, go
	li	$v0, 1
	jr	$ra
go:
	move	$s0, $a0	# s0 = grid
	move	$s1, $a1	# s1 = i = 0
	
	sll	$t0, $s1, 2	# "i * 4"
	add	$s2, $s0, $t0	# s2 = grid + i (!)
	lw	$t0, 0($s2)	# grid[i]
	bnez	$t0, notempty	# grid[i] == 0

	li	$t0, 9
	div	$s1, $t0	# div i, 9
	mflo	$s3		# s3 = row = i//9
	mfhi	$s4		# s4 = col = i%9
	li	$s5, 1		# s5 = test = 1
test:	
	beq	$s5, 10, endtest	# test <= 9 

	move	$a0, $s0	# grid
	move	$a1, $s1	# i (position)
	move	$a2, $s4	# col
	move	$a3, $s5	# test
	jal	RowColCheck
	beqz	$v0, unsafe
	
	move	$a0, $s0	# grid
	move	$a1, $s3	# row
	move	$a2, $s4	# col
	move	$a3, $s5	# test
	jal	BoxCheck
	beqz	$v0, unsafe
	
	sw	$s5, 0($s2)	# grid[i] = test
	move	$a0, $s0
	jal	sudoku
	beqz	$v0, backtrack
	li	$v0, 1
	j	endSudoku	# endSudoku
	
backtrack:
	sw	$0, 0($s2)	# grid[i] = 0
unsafe:
	addi	$s5, $s5, 1	# test++
	j	test

notempty:
	move	$a0, $s0
	addi	$a1, $s1, 1
	jal	sudoku
	beqz	$v0, endtest
	li	$v0, 1
	j	endSudoku

endtest:
	li	$v0, 0		# values exhausted, all fail
	j	endSudoku

endSudoku:
	lw	$s5, 4($sp)
	lw	$s4, 8($sp)
	lw	$s3, 12($sp)
	lw	$s2, 16($sp)
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra
	
# RowColCheck(a0 = grid, a1 = i, a2 = col, a3 = test)
RowColCheck:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	
	move	$s0, $a0	# s0 = grid
	sub	$s1, $a1, $a2	# rowpos = i - col
	
	li	$t0, 0		# j = 0
rowchk:
	beq	$t0, 9, rowchkperfect	# beq instead of bge
	add	$t1, $s1, $t0	# rowpos + j
	sll	$t1, $t1, 2	# "(rowpos + j) * 4"
	add	$t1, $s0, $t1	# grid + rowpos + j
	lw	$t2, 0($t1)	# grid[rowpos + j]
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
	lw	$t2, 0($t1)	# grid[j]
	bne	$t2, $a3, colgood	# elif test dupe in col exist, col fail
	li	$v0, 0		# return 0
	j	RCret		# fail
colgood:
	addi	$t0, $t0, 9	# j += 9 (go to next col entry)
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
	
	# determine which subgrid, set to s0 = j
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
	li	$t0, 0	# k = 0
boxchk:
	beq	$t0, 3, boxgood
	li	$t1, 0	# l = 0
for3:	
	beq	$t1, 3, nextrow
	add	$t2, $s0, $t1
	sll	$t2, $t2, 2
	add	$t2, $a0, $t2
	lw	$t3, 0($t2)
	bne	$t3, $a3, good
	li	$v0, 0
	j	boxret
good:	
	addi	$t1, $t1, 1
	j	for3
nextrow:
	addi	$t0, $t0, 1
	addi	$s0, $s0, 9
	j	boxchk

boxgood:
	li	$v0, 1		# return 1 when all checks passed
boxret:
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	lw	$ra, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra

#printGrid()
printGrid:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	
	la	$s0, grid	# s0 = grid
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
	
.data
grid:	.space	512
