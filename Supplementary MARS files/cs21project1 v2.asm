# CS 21 LAB4 -- S2 AY 2021-2022
# Yenzy Urson S. Hebron -- 04/18/2022
# 202003090_4.asm -- 4x4 Sodoku Solver

.include "macros.asm"

.text
main:
	la	$s0, arr
	li	$t0, 0			# int i = 0
for1:	beq	$t0, 4, end1
	read_str(raw, 6)		# read input string up to newline \n
	lw	$s1, raw
	li	$t1, 0			# int j = 0
for2:	beq	$t1, 4, end2
	lb	$t2, 0($s1)
	subi	$t2, $t2, 30		# convert ASCII to number
	sb	$t2, 0($s0)
	srl	$s1, $s1, 8
	addi	$s0, $s0, 1
	addi	$t1, $t1, 1
	j	for2
end2:	
	addi	$s0, $s0, 32
	addi	$t0, $t0, 4
	j	for1
end1:
	exit()

	
.data
raw:	.space	8	# begins at 0x10010000
arr:	.space	64	# begins at 0x10010008
