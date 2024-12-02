# Print an integer from a register
.macro print_int (%x)
	li a7, 1
	mv a0, %x
	ecall
.end_macro

# Print a character from a register
.macro print_char(%x)
	li a7, 11
	mv a0, %x
	ecall
.end_macro

# Push onto the stack
.macro push(%x)
	addi sp, sp, -4
	sw	%x, (sp)
.end_macro

# Move from the top of the stack to register x
.macro pop(%x)
	lw	%x, (sp)
	addi sp, sp, 4
.end_macro

# Print a string
.macro print_string (%x)
	.data
	string: .asciz %x
	.align 2
	.text
	push (a0)
	li a7, 4
	la a0, string
	ecall
	pop	(a0)
.end_macro

# New line
.macro new_line
	li a7, 11
	li a0, '\n'
	ecall
.end_macro

# Input file path
.macro get_path(%str, %len)
	la      a0 %str
	li      a1 %len
	li      a7 8
	ecall
	push(s0)
	push(s1)
	push(s2)
	li	s0 '\n'
	la	s1	%str
next:
	lb	s2  (s1)
	beq s0	s2	replace
	addi s1 s1 1
	b	next
replace:
	sb	zero (s1)
	pop(s2)
	pop(s1)
	pop(s0)
.end_macro

# Open a file
.macro open(%file, %o)
	li   	a7 1024
	la      a0 %file
	li   	a1 %o
	ecall
.end_macro

# Read a file
.macro read(%desc, %str, %len)
	li   a7, 63
	mv   a0, %desc
	la   a1, %str
	li   a2, %len
	ecall
.end_macro

# Close a file
.macro close(%desc)
	li   a7, 57
	mv   a0, %desc
	ecall
.end_macro

# Write information to a file
.macro write(%desc, %str, %len)
	li   a7, 64
	mv   a0, %desc
	la   a1, %str
	li   a2, %len
	ecall
.end_macro

# Allocate memory
.macro allocate(%len)
	li a7, 9
	li a0, %len
	ecall
.end_macro

# Exit program
.macro exit
	li a7, 10
	ecall
.end_macro