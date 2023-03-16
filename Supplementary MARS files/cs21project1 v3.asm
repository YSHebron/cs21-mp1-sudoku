# CS 21 LAB4 -- S2 AY 2021-2022
# Yenzy Urson S. Hebron -- 04/18/2022
# 202003090_4.asm -- 4x4 Sodoku Solver

.include "macros.asm"

.text
main:
	la	$s0, arr
	li	$t0, 0
for1:	beq	$t0, 4, end1
	read_str(raw, 6)
	lw	$s1, raw
	sw	$s1, 0($s0)
	addi	$s0, $s0, 4
	addi	$t0, $t0, 1
	j	for1
end1:
	exit()

	
.data
raw:	.space	8	# begins at 0x10010000
arr:	.space	64	# begins at 0x10010008