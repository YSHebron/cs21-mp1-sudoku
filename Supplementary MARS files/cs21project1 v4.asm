# CS 21 LAB4 -- S2 AY 2021-2022
# Yenzy Urson S. Hebron -- 04/18/2022
# 202003090_4.asm -- 4x4 Sudoku Solver

.include "macros.asm"

.text
main:
	la	$s0, grid
	la	$s1, raw
	
	li	$t2, 0
for2:	
	beq	$t2, 4, end2
	read_str(raw, 12)
	
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
	
	la	$a0, grid
	li	$a1, $0
	jal	sudoku
	
	exit()
	

sudoku:
	addi	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$s3, 12($sp)
	
	bne	$a0, 16, notbase	# immediately check base case
	li	$v0, 1			# return 1 on base case
	jr	$ra
	
notbase:
	move	$s0, $a0		# s0 = int grid[] (pointer)
	move	$s1, $a1		# s1 = int pos
	
	srl	$s2, $s0, 2		# s2 = row = pos//4
	sll	$t0, $s2, 2		# t0 = row * 4
	sub	$s3, $s1, $t0		# s3 = col = pos - row * 4
	
	sll	$t0, $s1, 2		# "pos * 4" (convert to word increment) <MIPS>
	add	$t1, $s0, $t1		# *(grid + pos) <C>
	lw	$s4, 0($t1)		# t0 = grid[pos] <C>
	bne	$s4, 0, notempty
	
	li	$t0, 1			# test value
for3:
	bgt	$t0, 4, exhaust
	
	move	$a0, $s0
	move	$a1, $s2
	move	$a2, $s3
	move	$a3, $t0
	jal	RowColCheck
	move	$t1, $v0
	jal	BoxCheck
	move	$t2, $v1
	
	and	$t1, $t1, $t2
	beqz	$t1, unsafe
	sw	$t0, 0($s4)
	
	move	$a0, $s0
	move	$
	
unsafe:
	j	for3

exhaust:
	
notempty:
	
RowColCheck:

	
.data	
grid:	.space	64
raw:	.space	12