# CS 61C Summer 2015 Project 2-2 
# string.s

#==============================================================================
#                              Project 2-2 Part 1
#                               String README
#==============================================================================
# In this file you will be implementing some utilities for manipulating strings.
# The functions you need to implement are:
#  - strlen()
#  - strncpy()
#  - copy_of_str()
# Test cases are in linker-tests/test_string.s
#==============================================================================

.data
newline:	.asciiz "\n"
tab:	.asciiz "\t"

.text
#------------------------------------------------------------------------------
# function strlen()
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = string input
#
# Returns: the length of the string
#------------------------------------------------------------------------------
strlen:
	addiu $sp $sp -4 		# Prologue 
	sw $ra 0($sp)

	addiu $v0, $0, 0		# set v0 to 0 (our counter)
strlen_loop:				
	lb $t0, 0($a0)			# load a byte from the string into t0 
	beq $t0, $0, end_strlen	# If the byte is null then end
	addiu $v0, $v0, 1 		# increment the counter
	addiu $a0, $a0, 1       # increment the string pointer
	j strlen_loop			# Loop
end_strlen:

	lw $ra, 0($sp)			# Epilogue
	addiu $sp, $sp, 4  		
	jr $ra

#------------------------------------------------------------------------------
# function strncpy()
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = pointer to destination array
#  $a1 = source string
#  $a2 = number of characters to copy
#
# Returns: the destination array
#------------------------------------------------------------------------------
strncpy:
	addiu $sp $sp -4        	# Prologue (not necessary as it's a leaf function but wanted to be thorough)
	sw $ra 0($sp)
	
	move $t1, $a0				# copy pointer to destination array into t1
strncpy_loop:
	beq $a2, $0, strncpy_exit	# if number of char left to copy equals 0, exit  
	lb $t0, 0($a1) 				# load a byte from source string
	sb $t0, 0($a0) 				# store byte in destination string
	addi $a0, $a0, 1 			# increment destination array
	addi $a1, $a1, 1 			# increment source array
	addi $a2, $a2, -1 			# decrement chars left to copy
	j strncpy_loop				# loop
strncpy_exit:
	sb $0, 0($a0)				# add a null terminator
	move $v0, $t1				# load the start of dest array into v0

	lw $ra, 0($sp)				# Epilogue
	addiu $sp, $sp, 4
	jr $ra

#------------------------------------------------------------------------------
# function copy_of_str()
#------------------------------------------------------------------------------
# Creates a copy of a string. You will need to use sbrk (syscall 9) to allocate
# space for the string. strlen() and strncpy() will be helpful for this function.
# In MARS, to malloc memory use the sbrk syscall (syscall 9). See help for details.
#
# Arguments:
#   $a0 = string to copy
#
# Returns: pointer to the copy of the string
#------------------------------------------------------------------------------
copy_of_str:
	addiu $sp $sp -8  		# Prologue 
	sw $s0 4($sp)
	sw $ra 0($sp)

	move $s0 $a0 			# set s0 to passed in string pointer
	
	jal strlen  			# get the length of the string
	
	move $a0 $v0 			# set a0 to number of bytes to allocate for syscall 
	
	li $v0 9 				# load 9 into v0 for syscall
	syscall 				# malloc memory 
	
	move $a2 $a0 			# set a2 to length of string for strcpy
	# addiu $a2 $a2 1			# add one to string length for null terminator
	move $a1 $s0 			# set a1 to string source pointer for strcpy
	move $a0 $v0 			# set a0 to allocated address for strcpy
	
	jal strncpy 			# copy string into a0
	
	lw $ra 0($sp)
	lw $s0 4($sp)	 		# Epilogue
	addiu $sp $sp 8
	
	jr $ra

###############################################################################
#                 DO NOT MODIFY ANYTHING BELOW THIS POINT                       
###############################################################################

#------------------------------------------------------------------------------
# function streq() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = string 1
#  $a1 = string 2
#
# Returns: 0 if string 1 and string 2 are equal, -1 if they are not equal
#------------------------------------------------------------------------------
streq:
	beq $a0, $0, streq_false	# Begin streq()
	beq $a1, $0, streq_false
streq_loop:
	lb $t0, 0($a0)
	lb $t1, 0($a1)
	addiu $a0, $a0, 1
	addiu $a1, $a1, 1
	bne $t0, $t1, streq_false
	beq $t0, $0, streq_true
	j streq_loop
streq_true:
	li $v0, 0
	jr $ra
streq_false:
	li $v0, -1
	jr $ra			# End streq()

#------------------------------------------------------------------------------
# function dec_to_str() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Convert a number to its unsigned decimal integer string representation, eg.
# 35 => "35", 1024 => "1024". 
#
# Arguments:
#  $a0 = int to write
#  $a1 = character buffer to write into
#
# Returns: the number of digits written
#------------------------------------------------------------------------------
dec_to_str:
	li $t0, 10			# Begin dec_to_str()
	li $v0, 0
dec_to_str_largest_divisor:
	div $a0, $t0
	mflo $t1		# Quotient
	beq $t1, $0, dec_to_str_next
	mul $t0, $t0, 10
	j dec_to_str_largest_divisor
dec_to_str_next:
	mfhi $t2		# Remainder
dec_to_str_write:
	div $t0, $t0, 10	# Largest divisible amount
	div $t2, $t0
	mflo $t3		# extract digit to write
	addiu $t3, $t3, 48	# convert num -> ASCII
	sb $t3, 0($a1)
	addiu $a1, $a1, 1
	addiu $v0, $v0, 1
	mfhi $t2		# setup for next round
	bne $t2, $0, dec_to_str_write
	jr $ra			# End dec_to_str()
