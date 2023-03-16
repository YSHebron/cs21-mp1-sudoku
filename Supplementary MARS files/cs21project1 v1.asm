# CS 21 LAB4 -- S2 AY 2021-2022
# Yenzy Urson S. Hebron -- 04/18/2022
# 202003090_4.asm -- 4x4 Sodoku Solver

.include "macros.asm"

.text
main:
	read_str(raw, 6)	# read input string up to newline \n
	read_str(raw, 6)
	read_str(raw, 6)
	read_str(raw, 6)
	li	$t0, 'A'
	sw	$t0, arr
	exit()
	
get_input:
	addi	$sp, $sp, 32
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	
	li	$t0, 0
for1:	beq	$t0, 4, end1
	
	do_syscall(8)
	move	$s0, $v0
	
for2:	li	$t1, 0
	beq	$t0, 4, end2
	
	rem	$s1, $s0, 10
	sw	$s1, arr($s0)

end1:
end2:
	
	
	
	
.data
raw:	.space	8
arr:	.space	64	# begins at 0x10010008