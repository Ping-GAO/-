#
# COMP1521 18s1 -- Assignment 1 -- Worm on a Plane!
#
# Base code by Jashank Jeremy and Wael Alghamdi
# Tweaked (severely) by John Shepherd
#
# Set your tabstop to 8 to make the formatting decent

# Requires:
#  - [no external symbols]

# Provides:
	.globl	wormCol
	.globl	wormRow
	.globl	grid
	.globl	randSeed

	.globl	main
	.globl	clearGrid
	.globl	drawGrid
	.globl	initWorm
	.globl	onGrid
	.globl	overlaps
	.globl	moveWorm
	.globl	addWormToGrid
	.globl	giveUp
	.globl	intValue
	.globl	delay
	.globl	seedRand
	.globl	randValue

	# Let me use $at, please.
	.set	noat

# The following notation is used to suggest places in
# the program, where you might like to add debugging code
#
# If you see e.g. putc('a'), replace by the three lines
# below, with each x replaced by 'a'
#
# print out a single character
# define putc(x)
# 	addi	$a0, $0, x
# 	addiu	$v0, $0, 11
# 	syscall
# 
# print out a word-sized int
# define putw(x)
# 	add 	$a0, $0, x
# 	addiu	$v0, $0, 1
# 	syscall

####################################
# .DATA
.data

	.align 4
wormCol:	.space	40 * 4
	.align 4
wormRow:	.space	40 * 4
	.align 4
grid:		.space	20 * 40 * 1
randSeed:	.word	0
main__0:	.asciiz "Invalid Length (4..20)"
main__1:	.asciiz "Invalid # Moves (0..99)"
main__2:	.asciiz "Invalid Rand Seed (0..Big)"
main__3:	.asciiz "Iteration "
main__4:	.asciiz "Blocked!\n"

	# ANSI escape sequence for 'clear-screen'
main__clear:	.asciiz "\033[H\033[2J"
# main__clear:	.asciiz "__showpage__\n" # for debugging

giveUp__0:	.asciiz "Usage: "
giveUp__1:	.asciiz " Length #Moves Seed\n"

####################################
# .TEXT <main>
	.text
main:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4
# Uses: 	$a0, $a1, $v0, $s0, $s1, $s2, $s3, $s4
# Clobbers:	$a0, $a1

# Locals:
#	- `argc' in $s0
#	- `argv' in $s1
#	- `length' in $s2
#	- `ntimes' in $s3
#	- `i' in $s4

# Structure:
#	main
#	-> [prologue]
#	-> main_seed
#	  -> main_seed_t
#	  -> main_seed_end
#	-> main_seed_phi
#	-> main_i_init
#	-> main_i_cond
#	   -> main_i_step
#	-> main_i_end
#	-> [epilogue]
#	-> main_giveup_0
#	 | main_giveup_1
#	 | main_giveup_2
#	 | main_giveup_3
#	   -> main_giveup_common

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	sw	$s2, -20($sp)
	sw	$s3, -24($sp)
	sw	$s4, -28($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -28

	# save argc, argv
	add	$s0, $0, $a0
	add	$s1, $0, $a1
   
   
   
	# if (argc < 4) giveUp(argv[0],NULL);
	slti	$at, $s0, 4			# if(argc < 4) at = 1
	bne	$at, $0, main_giveup_0

	# length = intValue(argv[1]);
	addi	$a0, $s1, 4	# 1 * sizeof(word)
	lw	$a0, ($a0)	# (char *)$a0 = *(char **)$a0
	jal	intValue

	# if (length < 4 || length >= 40)
	#     giveUp(argv[0], "Invalid Length");
	# $at <- (length < 4) ? 1 : 0
	slti	$at, $v0, 4
	bne	$at, $0, main_giveup_1
	# $at <- (length < 40) ? 1 : 0
	slti	$at, $v0, 40
	beq	$at, $0, main_giveup_1
	# ... okay, save length
	add	$s2, $0, $v0

	# ntimes = intValue(argv[2]);
	addi	$a0, $s1, 8	# 2 * sizeof(word)
	lw	$a0, ($a0)
	jal	intValue

	# if (ntimes < 0 || ntimes >= 100)
	#     giveUp(argv[0], "Invalid # Iterations");
	# $at <- (ntimes < 0) ? 1 : 0
	slti	$at, $v0, 0
	bne	$at, $0, main_giveup_2
	# $at <- (ntimes < 100) ? 1 : 0
	slti	$at, $v0, 100
	beq	$at, $0, main_giveup_2
	# ... okay, save ntimes
	add	$s3, $0, $v0

main_seed:
	# seed = intValue(argv[3]);
	add	$a0, $s1, 12	# 3 * sizeof(word)
	lw	$a0, ($a0)
	jal	intValue

	# if (seed < 0) giveUp(argv[0], "Invalid Rand Seed");
	# $at <- (seed < 0) ? 1 : 0
	slt	$at, $v0, $0
	bne	$at, $0, main_giveup_3

main_seed_phi:
	add	$a0, $0, $v0
	jal	seedRand

	# start worm roughly in middle of grid

	# startCol: initial X-coord of head (X = column)
	# int startCol = 40/2 - length/2;
	addi	$s4, $0, 2
	addi	$a0, $0, 40
	div	$a0, $s4
	mflo	$a0
	# length/2
	div	$s2, $s4
	mflo	$s4
	# 40/2 - length/2
	sub	$a0, $a0, $s4

	# startRow: initial Y-coord of head (Y = row)
	# startRow = 20/2;
	addi	$s4, $0, 2
	addi	$a1, $0, 20
	div	$a1, $s4
	mflo	$a1

	# initWorm($a0=startCol, $a1=startRow, $a2=length)
	add	$a2, $0, $s2
	jal	initWorm

main_i_init:
	# int i = 0;
	add	$s4, $0, $0
main_i_cond:
	# i <= ntimes  ->  ntimes >= i  ->  !(ntimes < i)
	#   ->  $at <- (ntimes < i) ? 1 : 0
	slt	$at, $s3, $s4
	bne	$at, $0, main_i_end 
	# clearGrid();
	jal	clearGrid
   nop
	# addWormToGrid($a0=length);
	add	$a0, $0, $s2
	jal	addWormToGrid
   nop
   
   
	# printf(CLEAR)
	
	la	$a0, main__clear
	addiu	$v0, $0, 4	
	syscall
   
	# printf("Iteration ")
	
	la	$a0,main__3
	addiu	$v0, $0, 4
	syscall
	   
   
	# printf("%d",i)
	add	$a0, $0, $s4
	addiu	$v0, $0, 1	# print_int
	syscall

	# putchar('\n')
	addi	$a0, $0, 0x0a
	addiu	$v0, $0, 11	# print_char
	syscall
	
	

	# drawGrid();
	jal	drawGrid
   nop
	# Debugging? print worm pos as (r1,c1) (r2,c2) ...

	# if (!moveWorm(length)) {...break}
	add	$a0, $0, $s2
	jal	moveWorm
	bne	$v0, $0, main_moveWorm_phi

	# printf("Blocked!\n")
	la	$a0, main__4
	addiu	$v0, $0, 4	# print_string
	syscall

	# break;
	j	main_i_end



main_moveWorm_phi:
	addi	$a0, $0, 1
	#jal	delay

main_i_step:
	addi	$s4, $s4, 1
	j	main_i_cond
main_i_end:

	# exit (EXIT_SUCCESS)
	# ... let's return from main with `EXIT_SUCCESS' instead.
	addi	$v0, $0, 0	# EXIT_SUCCESS

main__post:
	# tear down stack frame
	lw	$s4, -24($fp)
	lw	$s3, -20($fp)
	lw	$s2, -16($fp)
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra

main_giveup_0:
	add	$a1, $0, $0	# NULL
	j	main_giveup_common
main_giveup_1:
	la	$a1, main__0	# "Invalid Length"
	j	main_giveup_common
main_giveup_2:
	la	$a1, main__1	# "Invalid # Iterations"
	j	main_giveup_common
main_giveup_3:
	la	$a1, main__2	# "Invalid Rand Seed"
	# fall through
main_giveup_common:
	# giveUp ($a0=argv[0], $a1)
	lw	$a0, ($s1)	# argv[0]
	jal	giveUp		# never returns

####################################
# clearGrid() ... set all grid[][] elements to '.'
# .TEXT <clearGrid>
	.text
clearGrid:

# Frame:	$fp, $ra, $s0, $s1
# Uses: 	$s0, $s1, $t1, $t2
# Clobbers:	$t1, $t2

# Locals:
#	- `row' in $s0
#	- `col' in $s1
#	- `&grid[row][col]' in $t1
#	- '.' in $t2

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -16

### TODO: Your code goes here
#	/*void clearGrid()
#{
#	for (int row = 0; row < NROWS; row++) {
#		for (int col = 0; col < NCOLS; col++) {
#			grid[row][col] = '.';
#		}
#	}
#}
	

   la $t1, grid 		#	&grid[row][col]
	#li $t2, '.'
	li $t3, 0			#   row
	li $t4, 0			#	col
	li $t5, 40
	li $t6, 20
   
   

	clearGrid_loop1:	
	slt $t7, $t3, $t6		# if(row<40)
	beq $t7, $0,clearGrid_end1
	li $t4, 0			#	col
	clearGrid_loop2:
		slt $t7, $t4, $t5
		beq $t7, $0, clearGrid_end2
		li $t7,0
		li $t2,1
		mul $t7, $t3, $t5
		mul $t7, $t7, $t2
		mul $t2, $t2, $t4
		add $t7, $t7, $t2
		add $t7, $t7, $t1

		#li $t2, '.'
		addi $t2, $0, '.'
		sb $t2, ($t7)
   		
    

		addi $t4, $t4, 1
		j clearGrid_loop2
	clearGrid_end2:
	
	addi $t3, $t3, 1
   j clearGrid_loop1
clearGrid_end1:








	# tear down stack frame
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# drawGrid() ... display current grid[][] matrix
# .TEXT <drawGrid>
	.text
drawGrid:

# Frame:	$fp, $ra, $s0, $s1, $t1
# Uses: 	$s0, $s1
# Clobbers:	$t1

# Locals:
#	- `row' in $s0
#	- `col' in $s1
#	- `&grid[row][col]' in $t1

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -16

### TODO: Your code goes here
   la $t1, grid 		#	&grid[row][col]
	# li $t2, '.'
	li $t3, 0			#   row
	li $t4, 0			#	col
	
	# really weirld bug my 
	# constant dont work 
	#  only in this function
	
	
	
	#lw $s0, NCOLS
	#lw $s1, NROWS
   li $s0, 40
   li $s1, 20



drawGrid_loop1:	
	slt $t7, $t3, $s1		# if(row<20)
	beq $t7, $0,drawGrid_end1
	li $t4, 0			#	col
	drawGrid_loop2:
		slt $t2, $t4, $s0
		beq $t2, $0, drawGrid_end2
		li $t5,0
		li $t6,1
		mul $t5, $t3, $s0
		mul $t5, $t5, $t6
		mul $t6, $t6, $t4
		add $t5, $t5, $t6
		add $t5, $t5, $t1

		lb $t2, ($t5)
		move $a0, $t2
		li $v0,11
		syscall
      
      
      
		addi $t4, $t4, 1
		j drawGrid_loop2
	drawGrid_end2:
		li $a0, '\n'
		li $v0,11
		syscall
		addi $t3, $t3, 1
      j drawGrid_loop1
drawGrid_end1:

   
	# tear down stack frame
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# initWorm(col,row,len) ... set the wormCol[] and wormRow[]
#    arrays for a worm with head at (row,col) and body segements
#    on the same row and heading to the right (higher col values)
# .TEXT <initWorm>
	.text
initWorm:

# Frame:	$fp, $ra
# Uses: 	$a0, $a1, $a2, $t0, $t1, $t2
# Clobbers:	$t0, $t1, $t2

# Locals:
#	- `col' in $a0
#	- `row' in $a1
#	- `len' in $a2
#	- `newCol' in $t0
#	- `nsegs' in $t1
#	-  wormCol[] in $t2
#	-  wormRow[] in $t3
# 	temp in t4
#	temp in t5

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8

### TODO: Your code goes here
	#int nsegs;
	#int newCol = col+1;

	#wormCol[0] = col; wormRow[0] = row;
	#for (nsegs = 1; nsegs < len; nsegs++) {
	#	if (newCol == NCOLS) break;
	#	wormCol[nsegs] = newCol++;
	#	wormRow[nsegs] = row;
	#}
	move $t0, $a0				# use t0 to store newCol
     
   
	 #move $a0, $a1
	 #li $v0, 1
	 #syscall
	#................@oooooooo...............
	# constant working
	#lw $a0,NCOLS
	#li $v0,1
	#syscall


	addi $t0, $t0, 1			# t0++	
	li $t1, 1 					# nsegs = 1 
	
	la $t2, wormCol
	la $t3, wormRow
   
	sw $a0, ($t2)					# wormCol[0] = col;
	sw $a1, ($t3)					# wormRow[0] = row;
   
initWorm_loop1:
	# if(nsegs < len) $t4 = 1
	slt $t4, $t1, $a2
	beq $t4, $0, initWorm_end1

	# if (newCol == NCOLS) break;
	li $t5, 40				
	beq $t0, $t5, initWorm_end1 

	li $t6, 0
	add $t6, $t6, $t1
	sll $t6, $t6, 2 				# t6 *= 4
	
	#move $a0, $t6
	#li $v0, 1
	#syscall
	
	add $t6, $t6, $t2
	sw $t0, ($t6)

	li $t7, 0
	add $t7, $t7, $t1
	sll $t7, $t7, 2
	add $t7, $t7, $t3
	sw $a1, ($t7)

	addi $t0, $t0, 1

	addi $t1, $t1, 1				# nsegs++
	j initWorm_loop1


initWorm_end1:

	# test code
	#la $t5, wormCol
	#la $t6, wormRow
	#li $t1, 0
#	li $t2, 9
#test_loop1:
#	slt $t3, $t1, $t2    # if(i<9)
#	beq $t3,$0,test_end1
#	li $t4, 0
#	add $t4, $t4, $t1
#	sll $t4, $t4,2
#	add $t4,$t4, $t6
#	lw $a0, ($t4)
#	li $v0, 1
#	syscall
	
#	li $a0, '\n'
#	li $v0, 11
#	syscall

#	addi $t1, $t1, 1
#	j test_loop1

#test_end1:

	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# ongrid(col,row) ... checks whether (row,col)
#    is a valid coordinate for the grid[][] matrix
# .TEXT <onGrid>
	.text
onGrid:

# Frame:	$fp, $ra
# Uses: 	$a0, $a1, $v0
# Clobbers:	$v0
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw  $a0, -12($sp)
	sw  $a1, -16($sp)
	sw  $t0, -20($sp)
	sw  $t1, -24($sp)
	sw  $t2, -28($sp)
	sw  $t3, -32($sp)
	sw  $t4, -36($sp)
	sw  $t5, -40($sp)
	sw  $t6, -44($sp)
	sw  $t7, -48($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -48
# Locals:
#	- `col' in $a0
#	- `row' in $a1

# Code:
	move $t1, $a0			# t0 row
	move $t0, $a1     		# t1 col
   
   #li $a0, 'a'
   #li $v0,11
   #syscall
   
   #move $a0, $t0
   #li $v0,1
   #syscall
   
   #li $a0, 'b'
   #li $v0,11
   #syscall
   
	#li $t0,20
	#move $a0, $t0
	#li $v0,1
	#syscall

	#li $a0, '\n'
	#li $v0,11
	#syscall


	slti $t2, $t1, 0        # if(col < 0) $t2=1

	beq $t2, $0, Else1
	li $t2,0
	j Continue1
	Else1:
	li $t2, 1
   Continue1:

	#move $a0, $t2
	#li $v0,1
	#syscall

	#li $a0, '\n'
	#li $v0,11
	#syscall
   
   slti $t3, $t1, 40          # if(col < NCOLS)
   #move $a0, $t3             # t3 store the result
	#li $v0,1
	#syscall

	#li $a0, '\n'
	#li $v0,11
	#syscall
   
   slti $t4, $t0, 0        # if(row < 0) $t2=1

	beq $t4, $0, Else2
	li $t4,0
	j Continue2
	Else2:
	li $t4, 1
   Continue2:
   #move $a0, $t4             # t4 store the result
	#li $v0,1
	#syscall

	#li $a0, '\n'
	#li $v0,11
	#syscall
   slti $t5, $t0, 20          # if(row < NROWS)
   
   and $v0,$t2, $t3
   and $v0,$v0, $t4
   and $v0, $v0, $t5
   
   #move $t0, $v0
   
   #move $a0, $t5
   #li $v0, 1
   #syscall
   #li $a0, '\n'
   #li $v0,11
   #syscall
   
   #move $v0, $t0

### TODO: complete this function

	# set up stack frame

    # code for function

	# tear down stack frame
	lw	$t7, -44($fp)
	lw  $t6, -40($fp)
	lw  $t5, -36($fp)
	lw  $t4, -32($fp)
	lw  $t3, -28($fp)
	lw $t2, -24($fp)
	lw	$t1, -20($fp)
	lw	$t0, -16($fp)
	lw  $a1, -12($fp)
	lw  $a0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# overlaps(r,c,len) ... checks whether (r,c) holds a body segment
# .TEXT <overlaps>
	.text
overlaps:

# Frame:	$fp, $ra
# Uses: 	$a0, $a1, $a2
# Clobbers:	$t6, $t7
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw  $a0, -12($sp)
	sw  $a1, -16($sp)
	sw  $a2, -20($sp)
	sw  $t0, -24($sp)
	sw  $t1, -28($sp)
	sw  $t2, -32($sp)
	sw  $t3, -36($sp)
	sw  $t4, -40($sp)
	sw  $t5, -44($sp)
	sw  $t6, -48($sp)
	sw  $t7, -52($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -52
# Locals:
#	- `col' in $a0
#	- `row' in $a1
#	- `len' in $a2
#	- `i' in $t6

# Code:
	li $t0, 0				# i = 0
	la $t2, wormCol
	la $t3, wormRow

	overlaps_loop1:
		slt $t1, $t0, $a2
		beq $t1, $0, overlaps_end1
		li $t4, 4
		li $t5, 0

		mul $t4, $t4, $t0
		add $t5, $t4, $t2

		lw $t6, ($t5)
		beq $t6, $a0, Else3
		li $t7, 0

		j Continue3
		Else3:
		li $t7, 1					# t7 hold result
		Continue3:

		li $t4, 4
		li $t5, 0

		mul $t4, $t4, $t0
		add $t5, $t4, $t3

		lw $t6, ($t5)
		beq $t6, $a1, Else4
		li $t4, 0

		j Continue4
		Else4:
		li $t4, 1					# t4 hold result
		Continue4:


		and $t4, $t4, $t7

		li $t5, 1
		beq $t4, $t5, Return1



		addi $t0, $t0, 1
		j overlaps_loop1
	overlaps_end1:

	j Return0
	Return1:
		li $v0, 1
      j Clean_0
	Return0:
		li $v0, 0
      j Clean_0




### TODO: complete this function

	# set up stack frame

    # code for function
Clean_0:
	# tear down stack frame
	lw	$t7, -48($fp)
	lw  $t6, -44($fp)
	lw  $t5, -40($fp)
	lw  $t4, -36($fp)
	lw  $t3, -32($fp)
	lw 	$t2, -28($fp)
	lw	$t1, -24($fp)
	lw	$t0, -20($fp)
	lw  $a2, -16($fp)
	lw  $a1, -12($fp)
	lw  $a0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# moveWorm() ... work out new location for head
#         and then move body segments to follow
# updates wormRow[] and wormCol[] arrays

# (col,row) coords of possible places for segments
# done as global data; putting on stack is too messy
	.data
	.align 4
possibleCol: .space 8 * 4	# sizeof(word)
possibleRow: .space 8 * 4	# sizeof(word)

# .TEXT <moveWorm>
	.text
moveWorm:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7
# Uses: 	$s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7, $t0, $t1, $t2, $t3
# Clobbers:	$t0, $t1, $t2, $t3

# Locals:
#	- `col' in $s0
#	- `row' in $s1
#	- `len' in $s2
#	- `dx' in $s3
#	- `dy' in $s4
#	- `n' in $s7
#	- `i' in $t0
#	- tmp in $t1
#	- tmp in $t2
#	- tmp in $t3
# 	- `&possibleCol[0]' in $s5
#	- `&possibleRow[0]' in $s6

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	sw	$s2, -20($sp)
	sw	$s3, -24($sp)
	sw	$s4, -28($sp)
	sw	$s5, -32($sp)
	sw	$s6, -36($sp)
	sw	$s7, -40($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -40

### TODO: Your code goes here
	

	
	la $s5, possibleCol
	la $s6, possibleRow

	li $s7, 0   # n = 0
	li $s3, -1
	#move $a0, $t1 
	#li $v0, 1
	#syscall
	#li $a0, '\n'
	#li $v0,11
	#syscall
	la $t3, wormCol
	la $t4, wormRow
	moveWorm_loop1:
		slti $t2, $s3, 2  # if(dx <= 1 ) -> dex < 2
		beq $t2, $0, moveWorm_end1
			li $s4, -1
			moveWorm_loop2:
				slti $t6, $s4, 2
				beq $t6, $0, moveWorm_end2
				#li $s0, 0
				#li $s1, 0
				
				
				
				lw $s0, ($t3)
				add $s0, $s0, $s3 

				lw $s1, ($t4)
				add $s1, $s1, $s4

				move $a0, $s0
				move $a1, $s1
				
				
				
				jal onGrid
				move $t5, $v0           # t5 hold result
            #move $a0, $t5
            #li $v0,1
            #syscall
            #li $a0, '\n'
            #li $v0,11
            #syscall
				move $a0, $s0
				move $a1, $s1
				move $a2, $s2
				
				jal overlaps
				move $t7, $v0           # t7 hodl result
            
				nor $t7, $t7, $0

				and $t7, $t7, $t5
				
				beq $t7,$0,Else5
				#li $a0, 'a' 
				#li $v0, 11
				#syscall
				
				li $t5, 0 
				li $t7, 4
				mul $t5, $s7, $t7
				add $t5, $t5, $s5
				sw $s0, ($t5)

				li $t5, 0 
				li $t7, 4
				mul $t5, $s7, $t7
				add $t5, $t5, $s6
				sw $s1, ($t5)
				addi $s7, $s7, 1
            
				Else5: 
            
				addi $s4, $s4, 1
				j moveWorm_loop2
			moveWorm_end2:
		addi $s3, $s3, 1
		j moveWorm_loop1
	moveWorm_end1:
   
   #move $a0, $s7
   #li $v0,1
  # syscall
   
   #li $a0, 'a'
   #li $v0,11
   #syscall
   
	beq $s7, $0, Return_0

	move $t0, $s2
	addi $t0, $t0, -1

	moveWorm_loop3:
		slt $t1, $0, $t0
		beq	$t1, $0, moveWorm_end3
		move $t2, $t0
		addi $t2, $t2, -1
		li $t5, 4
		mul $t5, $t5, $t2

		add $t6, $t5, $t4 					#wormRow[i-1]
		add $t7, $t5, $t3 

		lw $t1, ($t6)
		lw $t2, ($t7)

		li $t5, 4
		mul $t5, $t5, $t0
		add $t7, $t5, $t4
		add $t6, $t5, $t3

		sw $t1, ($t7)
		sw $t2, ($t6)
		addi $t0, $t0, -1
		j moveWorm_loop3
	moveWorm_end3:
    
	#li $a0, 'n'
	#li $v0,11
	#syscall
	move $a0, $s7
	
	#li $v0,1
	#syscall
	jal randValue
   
	move $t0, $v0
	#li $a0, 'i'
	#li $v0,11
	#syscall
	
	#move $a0, $t0
	#li $v0,1
	#syscall
	
	li $t2, 4
	mul $t0, $t0, $t2
	add $t5, $t0, $s6
	lw $t6, ($t5)

	sw $t6, ($t4)

	add $t5, $t0, $s5
	lw $t6, ($t5)
	sw $t6, ($t3)
	j Return_1

	
	
   Return_0:
	li $v0, 0
	j Clean
   Return_1:
	li $v0, 1
   j Clean
	# tear down stack frame
	Clean:
	lw	$s7, -36($fp)
	lw	$s6, -32($fp)
	lw	$s5, -28($fp)
	lw	$s4, -24($fp)
	lw	$s3, -20($fp)
	lw	$s2, -16($fp)
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)

	jr	$ra

####################################
# addWormTogrid(N) ... add N worm segments to grid[][] matrix
#    0'th segment is head, located at (wormRow[0],wormCol[0])
#    i'th segment located at (wormRow[i],wormCol[i]), for i > 0
# .TEXT <addWormToGrid>
	.text
addWormToGrid:

# Frame:	$fp, $ra, $s0, $s1, $s2, $s3
# Uses: 	$a0, $s0, $s1, $s2, $s3, $t1
# Clobbers:	$t1

# Locals:
#	- `len' in $a0
#	- `&wormCol[i]' in $s0
#	- `&wormRow[i]' in $s1
#	- `grid[row][col]' s2
#	- `i' in $t0

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	sw	$s0, -12($sp)
	sw	$s1, -16($sp)
	sw	$s2, -20($sp)
	sw	$s3, -24($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -24
	
	
	

### TODO: your code goes here
	la $s0, wormCol
	la $s1, wormRow
	la $s2, grid
	lw $t1, ($s1) 	#int row
	lw $t2, ($s0)    # int col
   
   

	li $t6, 0
	li $t7, 1
	#lw $t4, NCOLS
	#lw $t5, NROWS
	li $t4, 40
	li $t5, 20
	
	mul $t6, $t1, $t4
	mul $t6, $t6, $t7
	mul $t7, $t7, $t2
	add $t6, $t6, $t7
	add $t6, $t6, $s2
	#li $t4, '@'
	addi $t4, $0, '@'
	sb $t4, ($t6)

   
   
   
   
	li $t0,1
	addWormTogrid_loop1:
		slt $t3, $t0, $a0
		beq $t3 , $0, addWormTogrid_end1
		li $t4, 4
		li $t5, 0
		mul $t4, $t4, $t0
		add $t5, $t4, $s1
		lw $t1, ($t5)

		li $t5, 0
		add $t5, $t4, $s0
		lw $t2, ($t5)

		li $t6, 0
		li $t7, 1
		#lw $t4, NCOLS
		#lw $t5, NROWS
		li $t4, 40
	   li $t5, 20
		mul $t6, $t1, $t4
		mul $t6, $t6, $t7
		mul $t7, $t7, $t2
		add $t6, $t6, $t7
		add $t6, $t6, $s2
		#li $t4, 'o'
      addi $t4, $0, 'o'
		sb $t4, ($t6)

		addi $t0, $t0, 1
		j addWormTogrid_loop1
	addWormTogrid_end1:






	# tear down stack frame
	lw	$s3, -20($fp)
	lw	$s2, -16($fp)
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra

####################################
# giveUp(msg) ... print error message and exit
# .TEXT <giveUp>
	.text
giveUp:

# Frame:	frameless; divergent
# Uses: 	$a0, $a1
# Clobbers:	$s0, $s1

# Locals:
#	- `progName' in $a0/$s0
#	- `errmsg' in $a1/$s1

# Code:
	add	$s0, $0, $a0
	add	$s1, $0, $a1

	# if (errmsg != NULL) printf("%s\n",errmsg);
	beq	$s1, $0, giveUp_usage

	# puts $a0
	add	$a0, $0, $s1
	addiu	$v0, $0, 4	# print_string
	syscall

	# putchar '\n'
	add	$a0, $0, 0x0a
	addiu	$v0, $0, 11	# print_char
	syscall

giveUp_usage:
	# printf("Usage: %s #Segments #Moves Seed\n", progName);
	la	$a0, giveUp__0
	addiu	$v0, $0, 4	# print_string
	syscall

	add	$a0, $0, $s0
	addiu	$v0, $0, 4	# print_string
	syscall

	la	$a0, giveUp__1
	addiu	$v0, $0, 4	# print_string
	syscall

	# exit(EXIT_FAILURE);
	addi	$a0, $0, 1 # EXIT_FAILURE
	addiu	$v0, $0, 17	# exit2
	syscall
	# doesn't return

####################################
# intValue(str) ... convert string of digits to int value
# .TEXT <intValue>
	.text
intValue:

# Frame:	$fp, $ra
# Uses: 	$t0, $t1, $t2, $t3, $t4, $t5
# Clobbers:	$t0, $t1, $t2, $t3, $t4, $t5

# Locals:
#	- `s' in $t0
#	- `*s' in $t1
#	- `val' in $v0
#	- various temporaries in $t2

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8

	# int val = 0;
	add	$v0, $0, $0

	# register various useful values
	addi	$t2, $0, 0x20 # ' '
	addi	$t3, $0, 0x30 # '0'
	addi	$t4, $0, 0x39 # '9'
	addi	$t5, $0, 10

	# for (char *s = str; *s != '\0'; s++) {
intValue_s_init:
	# char *s = str;
	add	$t0, $0, $a0
intValue_s_cond:
	# *s != '\0'
	lb	$t1, ($t0)
	beq	$t1, $0, intValue_s_end

	# if (*s == ' ') continue; # ignore spaces
	beq	$t1, $t2, intValue_s_step

	# if (*s < '0' || *s > '9') return -1;
	blt	$t1, $t3, intValue_isndigit
	bgt	$t1, $t4, intValue_isndigit

	# val = val * 10
	mult	$v0, $t5
	mflo	$v0

	# val = val + (*s - '0');
	sub	$t1, $t1, $t3
	add	$v0, $v0, $t1

intValue_s_step:
	# s = s + 1
	addi	$t0, $t0, 1	# sizeof(byte)
	j	intValue_s_cond
intValue_s_end:

intValue__post:
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra

intValue_isndigit:
	# return -1
	addi	$v0, $0, -1
	j	intValue__post

####################################
# delay(N) ... waste some time; larger N wastes more time
#                            makes the animation believable
# .TEXT <delay>
	.text
delay:

# Frame:	$fp, $ra
# Uses: 	$a0
# Clobbers:	$t0, $t1, $t2

# Locals:
#	- `n' in $a0
#	- `x' in $t6
#	- `i' in $t0
#	- `j' in $t1
#	- `k' in $t2

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8

### TODO: your code goes here
	li $t6, 3
	li $t0, 0
	delay_loop1:
		slt $t3, $t0, $a0
		beq $t3, $0, delay_end1
		li $t1, 0
		delay_loop2:
			slti $t4, $t1, 200
			beq $t4, $0, delay_end2


			li $t2, 0
			delay_loop3:
				slti $t5, $t2, 120
				beq $t5, $0, delay_end3
				li $t7, 3
				mul $t6, $t6, $t7
				addi $t2, $t2, 1
				j delay_loop3
			delay_end3:
			addi $t1, $t1,1
			j delay_loop2
		delay_end2:

		addi $t0, $t0 ,1
		j delay_loop1
	delay_end1:





	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra


####################################
# seedRand(Seed) ... seed the random number generator
# .TEXT <seedRand>
	.text
seedRand:

# Frame:	$fp, $ra
# Uses: 	$a0
# Clobbers:	[none]

# Locals:
#	- `seed' in $a0

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8

	# randSeed <- $a0
	sw	$a0, randSeed
   
   #li $a0, 1000
   #li $v0,1
   #syscall

seedRand__post:
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra

####################################
# randValue(n) ... generate random value in range 0..n-1
# .TEXT <randValue>
	.text
randValue:

# Frame:	$fp, $ra
# Uses: 	$a0
# Clobbers:	$t0, $t1

# Locals:	[none]
#	- `n' in $a0

# Structure:
#	rand
#	-> [prologue]
#       no intermediate control structures
#	-> [epilogue]

# Code:
	# set up stack frame
	sw	$fp, -4($sp)
	sw	$ra, -8($sp)
	la	$fp, -4($sp)
	addiu	$sp, $sp, -8

	# $t0 <- randSeed
	lw	$t0, randSeed
	
	#move $t5, $a0
	#li $a0,'r'
	#li $v0,11
	#syscall
	#move $a0, $t0
	#li $v0,1
   #syscall
   #move $a0, $t5
	# $t1 <- 1103515245 (magic)
	li	$t1, 0x41c64e6d

	# $t0 <- randSeed * 1103515245
	mult	$t0, $t1
	mflo	$t0

	# $t0 <- $t0 + 12345 (more magic)
	addi	$t0, $t0, 0x3039

	# $t0 <- $t0 & RAND_MAX
	and	$t0, $t0, 0x7fffffff

	# randSeed <- $t0
	sw	$t0, randSeed

	# return (randSeed % n)
	div	$t0, $a0
	mfhi	$v0


rand__post:
	# tear down stack frame
	lw	$ra, -4($fp)
	la	$sp, 4($fp)
	lw	$fp, ($fp)
	jr	$ra
