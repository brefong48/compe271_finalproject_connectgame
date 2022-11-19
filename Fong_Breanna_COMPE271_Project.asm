# for the bitmap display:
# set unit width and unit height in 8 by 8 bytes
# display width and height in 512 by 512 bytes
# base address for display : 0x10040000 (heap)

.data
  
start: 			.asciiz	"Welcome to Connect 4 by Breanna Fong\nThis game will have two players.\nPlease enter 1-7 to choose which column to place your color coordinated chip.\nAre you ready to start?\nEnter 'Y' for yes. OR Enter 'N' for no.\nAnswer: "
readyPrompt:		.asciiz	"\nMay the odds be ever in your favor.\n"
readyAnswer:		.space	64
player1Prompt: 		.asciiz	"\nPlayer 1's move: "
player2Prompt: 		.asciiz	"\nPlayer 2's move: "
player1Wins: 		.asciiz	"Player 1 Wins!\n"
player2Wins: 		.asciiz	"Player 2 Wins!\n"
instructions: 		.asciiz	"Please enter a number between 1-7\n"
fullColumnAlert:	.asciiz	"Column is full. Please select a different column.\n"
invalidAnswer:		.asciiz	"\nInvalid answer. Try again."
errorAnswer: 		.asciiz	"\nInvalid answer. Try again. \n"
tiePrompt: 		.asciiz	"It's a tie!\n"
nextRound: 		.asciiz	"\nWould you like to continue to the next round?\nEnter 'Y' for yes.\nEnter 'N' for no.\nAnswer:"
continueAnswer: 	.space	64
goodBye:		.asciiz "\n\nThank you for playing!"

colorBoard:			# hex color values
	.word 	0xADD8E6 	# light blue lines
	.word 	0xFFB6C1 	# light pink for Player 1
	.word 	0x90EE90 	# light green for Player 2
	.word	0xFFFFFF 	# white background

squareChip: 			# small horizontal lines to create a slot for game chip
	.word 0, 8, 0, 8, 0, 8, 0, 8, 0, 8, 0, 8, 0, 8, 0, 8
	
array: 	.byte 	0:49 		# array that represents the gameboard
  
pitch: 		.byte 	34	# for the sound
duration: 	.byte 	100
instrument: 	.byte 	7	# instrument: piano
volume: 	.byte 	100
  
.text

startGame:
	la 	$a0, 	start			# prints the start prompt
	li 	$v0, 	4
	syscall  
	la  	$a0, 	readyAnswer		# store their answer of Y or N
	li  	$a1, 	3
	li  	$v0, 	8
	syscall
	lb  	$t4, 	0($a0) 			# loads the $t4 byte
	beq 	$t4, 	'Y', 	readyGame	# if they say Y or y, it will jump to the begin the game
    	beq 	$t4, 	'y', 	readyGame
    	beq 	$t4,	'N',	gameOver	# if they say N or n, it will exit the program
    	beq 	$t4,	'n',	gameOver
    	bne 	$t4, 	'Y', 	errorPrompt	# else, it will print an error message to ask the player to try again
    	bne 	$t4, 	'y', 	errorPrompt
    	bne 	$t4,	'N',	errorPrompt
    	bne 	$t4,	'n',	errorPrompt
	jr	$ra				# jumps to the start of the loop

errorPrompt: 
	la 	$a0, 	errorAnswer		# prints the prompt to ask players if they are ready for the next round
	li 	$v0, 	4
	syscall
	jal	errorSound			# jumps to errorSound
	jal	startGame			# jumps to startGame
	jr	$ra				# jumps to the start of the loop

readyGame: 
	jal 	connect4Board			# jumps to the connect4board to print the game board
	la 	$a0, 	readyPrompt		# prints the ready prompt
	li 	$v0, 	4
	syscall  

.globl mainLoop
mainLoop: 

player1:
	la 	$a0, 	player1Prompt	# prints player one's turn 
    	li 	$v0, 	4
   	syscall 
   	li 	$v0, 	5		# gets player one's input
	syscall
	li 	$a0, 	1		# places input into array and checks for error
	jal 	inputCheck		# jumps to inputCheck
    	li 	$a0, 	1		# draws player 1 chip
	jal 	stackChips		# draws chip in the box
	jal 	winningCheck    	# checks if player 1 won
	jal	playSound		# plays a sound when it's player's turn
    
player2:
	la 	$a0, 	player2Prompt	# prints player two's turn
	li 	$v0, 	4
	syscall
	li 	$v0, 	5		# gets player two's input
	syscall
	li 	$a0, 	2		# places input into array and checks for error
	jal 	inputCheck		# jumps to inputCheck
    	li 	$a0, 	2		# draws player 2 chip
	jal 	stackChips		# draws chip in the box
	jal 	winningCheck  		# checks if player 2 won
	jal	playSound		# plays a sound when it's player's turn
	j 	mainLoop 		# jumps back to mainLoop
j	readyGame			# jumps back to readyGame

connect4Board:				# $a0 and $a1 are coordinates for the game board ($a0 = x, $a1 = y), $a2 = colors, $a3 = width of the pixels
	addi 	$sp, 	$sp, 	-4	# allocates 1 space for the stack
	sw 	$ra, 	($sp)		# saves $ra for stack
	li 	$a0, 	0		# loads $a0 to x = 0
	li 	$a1, 	0 		# loads $a1 to y = 0
	li 	$a2, 	3		# loads $a2 to prints white background
	li 	$a3, 	64 		# loads $a3 to 64 pixels 
	jal 	stackBox		# jumps to drawBox
	li 	$a0, 	0		# loads $a0 to x = 0
	li 	$a1, 	0		# loads $a1 to y = 0
	li 	$a2, 	0		# loads $a2 to light blue
	li 	$a3, 	64		# loads $a3 to 64 bytes 
	jal 	stackVerticalLine	# prints the vertical line	
	li 	$a0, 	9		# loads $a0 to x = 9
	jal 	stackVerticalLine	# prints the vertical line
	li 	$a0, 	18		# loads $a0 to x = 18
	jal 	stackVerticalLine	# prints the vertical line
	li 	$a0, 	27		# loads $a0 to x = 27
	jal 	stackVerticalLine	# prints the vertical line
	li 	$a0, 	36		# loads $a0 to x = 36
	jal 	stackVerticalLine	# prints the vertical line
	li 	$a0, 	45		# loads $a0 to x = 45
	jal 	stackVerticalLine	# prints the vertical line
	li 	$a0, 	54		# loads $a0 to x = 54
	jal 	stackVerticalLine	# prints the vertical line
	li 	$a0, 	63		# loads $a0 to x = 63
	jal 	stackVerticalLine	# prints the vertical line
	li 	$a0, 	0		# loads $a0 to x = 0
	li 	$a1, 	0		# loads $a1 to y = 0
	li 	$a2, 	0		# loads $a2 to light blue
	li 	$a3, 	64		# loads $a3 to 64 bytes 
	jal 	stackHorizontalLine	# prints the horizontal line
	li 	$a1, 	9		# loads $a1 to y = 9
	jal 	stackHorizontalLine	# prints the horizontal line
	li 	$a1, 	18		# loads $a1 to y = 18
	jal 	stackHorizontalLine	# prints the horizontal line
	li 	$a1, 	27		# loads $a1 to y = 27
	jal 	stackHorizontalLine	# prints the horizontal line
	li 	$a1, 	36		# loads $a1 to y = 36
	jal 	stackHorizontalLine	# prints the horizontal line
	li 	$a1, 	45		# loads $a1 to y = 45
	jal 	stackHorizontalLine	# prints the horizontal line
	li 	$a1, 	54		# loads $a1 to y = 54
	jal 	stackHorizontalLine	# prints the horizontal line
	li 	$a1, 	63		# loads $a1 to y = 63
	jal 	stackHorizontalLine	# prints the horizontal line
	lw 	$ra, 	($sp)		# restores $ra from stack
	addi 	$sp, 	$sp, 	4	# deallocates 1 space on the stack
	jr 	$ra			# jumps back to the start of loop when done

stackBox:				# $a0 = x, $a1 = y, $a2 = colors, $a3 = width of the pixels
	addi 	$sp, 	$sp, 	-24	# allocates 6 spaces for the stack
	sw 	$ra,	20($sp)		# saves $ra in stack
	sw 	$s0,	16($sp)		# saves $s0 in stack
	sw	$a0,	12($sp)		# saves $a0 in stack
	sw 	$a2,	8($sp)		# saves $a2 in stack	
	move	$s0,	$a3		# copies $a3 to $s0
	loopBox:
	sw 	$a1,	4($sp)		# saves $a1 for stack
	sw	$a3,	0($sp)		# saves $a3 for stack
	jal 	stackHorizontalLine	# jumps to stackHorizontalLine
	lw	$a3,	0($sp)		# restores $a3 from stack
	lw	$a2,	8($sp)		# restores $a2 from stack
	lw 	$a0,	12($sp)		# restores $a0 from stack
	addi	$a1,	$a1,	1	# increasing y value by 1
	addi 	$s0, 	$s0, 	-1	# decreasing width value	
	bne 	$0, 	$s0, 	loopBox	# loops until $s0 counter = 0	
	lw	$a1,	4($sp)		# restores $a1 from stack
	lw 	$s0, 	16($sp)		# restores $s0 from stack
	lw 	$ra, 	20($sp)		# restores $ra from stack
	addi 	$sp, 	$sp, 	24	# deallocates 6 spaces on the stack
	jr 	$ra			# jumps back to the start of loop when done 
	      
stackHorizontalLine:			# $a0 = x, $a1 = y, $a2 = colors, $a3 = width of the pixels
	addi 	$sp, 	$sp, 	-28	# allocates 7 spaces for the stack 
	sw 	$a3, 	24($sp)		# saves $a3 in stack
	sw 	$a0, 	20($sp)		# saves $a0 in stack
	sw 	$ra, 	16($sp)		# saves $ra in stack 
	sw 	$a1, 	12($sp)		# saves $a1 in stack
	sw 	$a2, 	8($sp)		# saves $a2 in stack
	loopHorizontal:
	sw 	$a0, 	4($sp)		# saves $a0 in stack
	sw 	$a3, 	0($sp)		# saves $a3 in stack
	jal 	drawDot			# jumps to drawDot
	lw 	$a3, 	0($sp)		# restores #a3 from stack
	lw 	$a2, 	8($sp)		# restores $a2 from stack
	lw 	$a0, 	4($sp)		# restores $a0 from stack
	lw 	$a1, 	12($sp)		# restores $a1 from stack
	addi 	$a3, 	$a3, 	-1	# decreasing the width from the pixel
	addi 	$a0, 	$a0, 	1	# adds to the x value
	bnez 	$a3, 	loopHorizontal	# if the width > 0, continue horizontal loop	
	lw 	$ra, 	16($sp)		# restores $ra from stack
	lw 	$a0, 	20($sp)		# restores $a0 from stack
	lw 	$a3, 	24($sp)		# restores $a3 from stack
	addi 	$sp, 	$sp, 	28	# deallocates 7 spaces on the stack
	jr 	$ra			# jumps back to the start of loop when done
	
stackVerticalLine:			# $a0 = x, $a1 = y, $a2 = colors, $a3 = width of the pixels
	addi 	$sp, 	$sp, 	-28	# allocates 7 spaces for the stack 
	sw 	$a3, 	24($sp)		# saves $a3 in stack	
	sw 	$a0, 	20($sp)		# saves $a0 in stack
	sw 	$ra, 	16($sp)		# saves $ra in stack 
	sw 	$a1, 	12($sp)		# saves $a1 in stack
	sw 	$a2, 	8($sp)		# saves $a2 in stack
	loopVertical:
	sw 	$a1, 	4($sp)		# saves $a0 in stack
	sw 	$a3, 	0($sp)		# saves $a3 in stack
	jal 	drawDot			# jumps to drawDot
	lw 	$a3, 	0($sp)		# restores #a3 from stack
	lw 	$a1, 	4($sp)		# restores $a1 from stack
	lw 	$a2, 	8($sp)		# restores $a2 from stack
	addi 	$a3, 	$a3, 	-1	# decreasing the width from the pixel
	addi 	$a1, 	$a1, 	1	# adds to the y value
	bnez 	$a3, 	loopVertical	# if the width > 0, continue vertical loop	
	lw 	$a1, 	12($sp)		# restores $a0 from the stack
	lw 	$ra, 	16($sp)		# restores $ra from the stack
	lw 	$a0, 	20($sp)		# restores $a0 from stack
	lw 	$a3, 	24($sp)		# restores $a3 from the stack
	addi 	$sp, 	$sp, 	28	# deallocates 7 spaces on the stack
	jr 	$ra			# jumps back to the start of loop when done

stackChips:				# $a0 =  players (1 & 2), $v0 = boxes (0 - 48)
	addi 	$sp, 	$sp, 	-12	# allocates 3 spaces from the stack
	sw	$ra,	($sp)		# saves $ra for stack
	sw	$a0,	4($sp)		# saves $a0 for stack
	sw 	$v0,	8($sp)		# saves $v0 for stack
	move 	$a2,	$a0		# copies the color of the chip to the coordinating players ( 1 & 2 ) 
	li 	$t7, 	7		# calculates address
	div	$v0,	$t7		# divides $v0 by the boxes
	mflo	$t7			# sets LO to quotient
	mfhi 	$t8			# sets HI to the remainder
	li 	$t9, 	55		# calculates the y address
	mul 	$t7, 	$t7, 	9	# multiplies 9 to the y
	mflo 	$t7			# sets LO as remainder
	sub 	$t7, 	$t9,	$t7 	# sets $t7 to ($t9-$t7)
	mul 	$t8, 	$t8, 	9	# calculates the x address
	addi 	$t8, 	$t8, 	1	# adds 1 to the x address
	move 	$a0, 	$t8		# copies address to $a registers for procedure call
	move 	$a1,	$t7		# copies $a1 to $t7
	jal	stackSquare		# jumps to stackSquare
	lw 	$v0, 	8($sp)		# restores $v0 from the stack
	lw 	$a0, 	4($sp)		# restores $a0 from the stack
	lw 	$ra, 	($sp)		# restores $ra from the stack
	addi 	$sp, 	$sp, 	4	# deallocates 1 space from the stack
	jr 	$ra			# jumps back to the start of loop when done

stackSquare:				# $a0 = x, $a1 = y, $a2 = colors
	addi 	$sp, 	$sp, 	-28 	# allocates 7 spaces for the stack
	sw 	$ra, 	20($sp)		# saves $ra in stack
	sw 	$s0, 	16($sp)		# saves $s0 in stack
	sw 	$a0, 	12($sp)		# saves $a0 in stack
	sw 	$a2, 	8($sp)		# saves $a2 in stack
	li 	$s2, 	0		# counter
	loopSquare:				# draws the circle in the given location
	sw 	$s2,	24($sp)			# saves $s2 in stack
	la 	$t1, 	squareChip		# loads the squareChip in bytes
	addi 	$t2,	$s2, 	0		# counter
	mul 	$t2, 	$t2, 	8		# uses counter vlaue to shoft the table's value
	add 	$t2, 	$t1, 	$t2		# gets the x-offset array index
	lw 	$t3, 	($t2)			# loads offset into $t3
	add 	$a0, 	$a0, 	$t3		# adds past x location to current x location
	addi 	$t2, 	$t2, 	4		# moves to stackHorizontalLine length in array
	lw 	$a3, 	($t2)			# loads line length 
	sw 	$a1, 	4($sp)			# saves $a1 in stack
	sw	$a3, 	0($sp)			# saves $a3 in stack
	jal	stackHorizontalLine		# jumps to stackHorizontalLine
	lw 	$a3, 	0($sp)			# restores $a3 from stack
	lw 	$a1, 	4($sp)			# restores $a1 from stack
	lw 	$a2, 	8($sp)			# restores $a2 from stack
	lw 	$a0, 	12($sp)			# restores $a0 from stack
	lw 	$s0, 	16($sp)			# restores $s0 from stack	
	lw 	$ra, 	20($sp)			# restores $ra from stack
	lw 	$s2, 	24($sp)			# restores $s2 from stack
	addi 	$a1, 	$a1, 	1		# increasing the y value
	addi 	$s2, 	$s2, 	1		# increasing counter
	bne 	$s2, 	8, 	loopSquare	# keep looping until counter = 50 (50 horizontal lines in 1 circle)
	addi 	$sp, 	$sp, 	28		# deallocates 7 spaces from the stack
	jr 	$ra				# jumps back to the start of loop when done
                                                                                                                                                                                  
drawDot:				# $a0 = x, $a1 = y, $a2 = colors
	addi	$sp, 	$sp, 	-8	# allocates 2 spaces for the stack 
	sw	$ra,	4($sp)		# saves $ra for stack
	sw	$a2,	0($sp)		# saves $a2 for stack
	jal 	calculateAddress	# jumps tp calculateAddress to calculate the memory address to write on
	lw 	$a2, 	0($sp)		# restores $a2 from stack
	sw 	$v0, 	0($sp)		# saves $v0 for the stack
	jal 	color			# jumps to color to get the color hex value
	lw 	$v0, 	0($sp)		# restores $v0 from stack
	sw 	$v1, 	($v0)		# writes the color value to its memory address
	lw 	$ra, 	4($sp)		# restores $ra from the stack
	addi 	$sp,	$sp,	8	# deallocates 2 spaces for the stack
	jr 	$ra			# jumps back to the start of loop when done

calculateAddress:				# $a0 = x, $a1 = y, $v0 = address
	sll 	$t1, 	$a0, 	2		# calculates for the x input
	sll 	$t2, 	$a1,	8		# calculates for the y input
	add 	$t3, 	$t1, 	$t2		# adds the two inputs together
	addi 	$v0, 	$t3, 	0x10040000	# adds the heap base to the two inputs
	jr 	$ra				# jumps back to the start of loop when done

color: 						# $a2 = colors, $ v1 = hex color
	la 	$t4,	colorBoard		# loads the colors for the board
	sll 	$a2,	$a2,	2		# shifts to the left twice
	add 	$a2, 	$a2,	$t4		# adds the colorBoard
	lw	$v1, 	($a2)			# adds the color value to hex color value
	jr 	$ra				# jumps to the start of the color loop

inputCheck:
	addi	$v0,	$v0,	-8		# allocates 2 spaces for the stack
	blt	$v0,	-7,	error		# if the range is greater than 7, then go to error
	bgt	$v0, 	-1,	error		# if the range is less than 1, then go to error
	moveCheck: 
	addi	$v0, 	$v0,	7		# increases the row for the next move
	bgt	$v0,	48, 	fullColumn	# if the column is full, goes to fullColumn
	lb	$t1,	array($v0)		# loads the byte from the array the player chose
	bnez	$t1,	moveCheck		# if this byte is filled, then try the next row
	sb	$a0,	array($v0)		# stores the byte in the array
	jr	$ra				# jumps to the start of the loop
	error:
	move	$t0,	$a0			# copies $a0 to $t0
	la	$a0, 	instructions		# prints the instuctions prompt
	li 	$v0, 	4			
	syscall
	jal	errorSound			# jumps to errorSound
	move 	$a0, 	$t0			# copies $t0 back to $a0
	j	playerPrompts			# jumps to the playerPrompts
	fullColumn:
	move 	$t0,	$a0			# copies $a0 to $t0
	la	$a0,	fullColumnAlert		# prints the full column alert
	li	$v0,	4
	syscall	
	move	$a0,	$t0			# copies $t0 back to $a0
	j	playerPrompts			# jumps to the playerPrompts

playerPrompts:			
	beq	$a0,	1,	player1		# if there's an error, prints the player 1 turn
	beq	$a0,	2,	player2		# if there's an error, prints the player 2 turn

winningCheck:					# $a0 = player, $v0 = chip's current location
	addi 	$sp, 	$sp, 	-4		# allocates 1 space for the stack
     	sw 	$ra, 	($sp)			# saves $ra for stack
        li 	$t9, 	7			# a constant 7 for left and right checkings
        
	# Horizontal Check
	li 	$t7, 	1			# counter for the winningPlayer
	move	$t2,	$v0			# sets $t2 to checking left from chip's last location
    	move	$t4,	$v0			# sets $t4 to checking right from chip's last location
    	goLeft:
    	la	$t0,	array($t2)		# loads address to the array
    	div	$t2,	$t9			# divides $t2 with $t9
    	mfhi 	$t8				# sets HI to remainder
    	beqz	$t8,	goRight			# if it equals 0, then checks the right
    	lb	$t1,	-1($t0)			# loads the byte
    	bne	$t1,	$a0,	goRight		# if it does not equal the player number, check right
    	addi	$t7,	$t7,	1		# moves to the next chip to the left
    	addi	$t2,	$t2,	-1		# counter
    	bgt	$t7,	3,	winningPlayer	# if a player has more than 3 chips connected, then they won
    	j	goLeft				# checks left
    	goRight:
    	la	$t0,	array($t4)		# loads address to the array
    	div	$t2,	$t9			# divides $t2 with $t9
    	mfhi 	$t8				# sets HI to remainder
    	beq	$t8,	6,	stopHorizontal	# if it equals 6, stop horizontal check
    	lb	$t1,	1($t0)			# loads the byte 
    	bne	$t1,	$a0,	stopHorizontal	# if it does not equal the player number, then stop horizontal check
    	addi	$t7,	$t7,	1		# counter
    	addi	$t4,	$t4,	1		# moves to the next chip to the right
    	bgt	$t7,	3,	winningPlayer	# if a player has more than 3 chips connected, then they won
    	j	goRight				# jump to goRight
    	stopHorizontal:				# stops horizontal check to start vertical check
    	
	# Vertical Check
	li 	$t7, 	1			# counter for the winningPlayer
	move	$t2,	$v0			# sets $t2 to checking up from chip's last location
    	move	$t4,	$v0			# sets $t4 to checking right from chip's last location		
    	goUp:
    	la	$t0,	array($t2)		# loads the address
    	bgt	$t2,	41,	goDown		# if it is greater than 41, then it's at the top row and must check down
    	lb	$t1,	7($t0)			# loads the byte of the left location
    	bne	$t1,	$a0,	goDown		# if it does not equal to player number, then go down
    	addi	$t7,	$t7,	1		# if it does equal the player number, check the next row
    	addi	$t2,	$t2,	7		# moves to the next chip above its location
    	bgt	$t7,	3,	winningPlayer	# if a player has more than 3 chips connected, then they won
    	j	goUp				# jump to goUp
     	goDown:
    	la	$t0,	array($t4)   		# loads the address	
    	blt	$t4,	7,	stopVertical	# the bottom row will end the vertical check
    	lb	$t1,	-7($t0)			# loads the byte of the loaction below
    	bne	$t1,	$a0,	stopVertical	# if it doe not equal the player number, then stop vertical check
    	addi	$t7,	$t7,	1		# counter
    	addi	$t4, 	$t4,	-7		# moves to the next chip below its location
    	bgt	$t7,	3,	winningPlayer	# if a player has more than 3 chips connected, then they won
    	j	goDown				# jump yo goDown
    	stopVertical:				# stops vertical check 
 	
	lw 	$ra, 	($sp)			# restores $ra from the stack
	addi 	$sp,	$sp, 	4		# deallocates 1 space from the stack
	jr 	$ra				# jumps back to the start of loop when done
	
playSound: 		
	li	$v0,	31		# plays a beep sound
	la	$a0, 	pitch
	la	$a1, 	duration 
	la 	$a2, 	instrument
	la 	$a3, 	volume 
	syscall
	jr 	$ra			# jumps back to the start of loop when done

errorSound: 
	li	$v0,	31		# plays an error sound
	la	$t6, 	pitch
	la	$t7, 	duration 
	la 	$t8, 	instrument
 	la 	$t9, 	volume 
 	addi	$t6,	$t6,	48	# moves pitch to 82
	move 	$a0, 	$t6 		# copies pitch to $a0
	move 	$a1, 	$t7 		# copies duration to $a1	
	move 	$a2, 	$t8		# copies instrument to $a2
	move 	$a3, 	$t9 		# copies volume to $a3
	syscall 
	jr 	$ra			# jumps back to the start of loop when done
	
tieGame: 
    	la 	$a0, 	tiePrompt	# prints the tie prompt
    	li 	$v0, 	4
    	syscall
    	jal 	askNewRound		# jumps to askNewRound

invalidPrompt:
	la 	$a0, 	invalidAnswer	# prints the prompt to ask players if they are ready for the next round
	li 	$v0, 	4
	syscall
	jal	askNewRound		# jumps to askNewRound
	jal 	errorSound		# jumps to errorSound
	jr	$ra			# jumps to the start of the loop
	
askNewRound: 
	la 	$a0, 	nextRound		# prints the prompt to ask players if they are ready for the next round
	li 	$v0, 	4
	syscall
	la  	$a0, 	continueAnswer		# store their answer of Y or N
	li  	$a1, 	3
	li  	$v0, 	8			# reads the players' answer
	syscall
	lb  	$t4, 	0($a0) 			# loads the $t4 byte
    	beq 	$t4, 	'Y', 	resetGame	# if they say Y or y, it will jump to the beginning of the game
    	beq 	$t4, 	'y', 	resetGame
    	beq 	$t4,	'N',	gameOver	# if they say N or n, it will jump to the end of the game
    	beq 	$t4,	'n',	gameOver
    	bne 	$t4, 	'Y', 	invalidPrompt	# if they do not write the right answer, it will print an error
    	bne 	$t4, 	'y', 	invalidPrompt
    	bne 	$t4,	'N',	invalidPrompt
    	bne 	$t4,	'n',	invalidPrompt
	jr 	$ra				# jumps to the start of the askNewRound loop   

winningPlayer:
	beq 	$a0, 	1,	player1won	# if player 1 wins, it will jump to the player 1 prompt. 
	beq 	$a0, 	2,	player2won	# if player 2 wins, it will jump to the player 2 prompt.
	player1won:
    	la 	$a0, 	player1Wins		# prints that player 1 won
    	li 	$v0, 	4
    	syscall
    	jal 	askNewRound			# jumps to askNewRound
	player2won:
    	la 	$a0, 	player2Wins		# prints that player 2 won
    	li 	$v0, 	4
    	syscall
	jal 	askNewRound			# jumps to askNewRound
	
    		
resetGame:
	jal 	connect4Board			# jumps to connect4Board
	jal 	mainLoop			# jumps to mainLoop
	
gameOver:	
	la 	$a0, 	goodBye			# prints goodbye message
    	li 	$v0, 	4
    	syscall				
	li   	$v0, 	10			# ends program 
	syscall

