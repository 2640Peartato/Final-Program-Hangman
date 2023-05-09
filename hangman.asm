#Names: Catalina Davis, Kenneth Hung, Ayanna Sanges-Chu
#Date: 05/14/23
#Objectives: Create a Hangman game
# - print rules to user
# - get user input for word used in game
# - 3 options for the user
#   - guess word, if correct instant win, else add 1 to counter
#   - guess character, if correct display char locations, else add 1 to counter
#   - give up, haha loser, game end

#macro getUserInt
.macro getUserInt
li $v0, 5
syscall
move $t0, $v0 #users int stored in $t0
.end_macro

#macro defString
.macro defString(%str)
li $v0, 4
la $a0, %str
syscall
.end_macro

#macro getInput
.macro getInput
#get user input string
#two arguments: $a0=address of the buffer and $al=length of the string
li $v0, 8
la $a0, userInput
la $a1, 51
syscall
#move content in buffer to another register
move $t1, $a0
.end_macro

.data
userInput: .space 51 #string length max is 50 chars
rules: .asciiz "\nChoose a word, you have 1 chance to guess a word, and 5 possible strikes when choosing a letter.\nIf you guess the wrong word, or choose 5 letters not in the word you lose."
wordRequest: .asciiz "\nSelect an int (1-5) and a word will be provided for the game: "
userMenu: .asciiz "\n~~~~~~~~~~~~~~Main Menu~~~~~~~~~~~~~~\n(1) guess word\n(2) guess a letter\n(3) give up\n(4) exit the game"
userChoice: .asciiz "\nPlease enter a number to choose an option: "
userGuess: .asciiz "\nEnter your guess: "
correctCharacterGuess:"\nCorrect letter!"
wrongCharacterGuess:"\nSorry wrong letter"
correctStringGuess:"\nCongratulations you guessed the correct word!"
wrongStringGuess:"\nIncorrect guess of the word"
exitMessage: .asciiz "\nThanks for playing!"
wordBank1: .asciiz "zebra"
wordBank2: .asciiz "grade"
wordBank3: .asciiz "ocean"
wordBank4: .asciiz "laser"
wordBank5: .asciiz "jerky"
test: .asciiz "\ntest"

#ascii art:
life1: .asciiz "	|-----|\n	|     |\n	      |\n	      |\n	      |\n	      |\n	---------\n"
life2: .asciiz "	|-----|\n	|     |\n	O     |\n	      |\n	      |\n	      |\n	---------\n"
life3: .asciiz "	|-----|\n	|     |\n	O     |\n	|     |\n	|     |\n	      |\n	---------\n"
life4: .asciiz "	|-----|\n	|     |\n	O     |\n       \\|     |\n	|     |\n	      |\n	---------\n"
life5: .asciiz "	|-----|\n	|     |\n	O     |\n       \\|/    |\n	|     |\n	      |\n	---------\n"
life6: .asciiz "	|-----|\n	|     |\n	O     |\n       \\|/    |\n	|     |\n       /      |\n	---------\n"
life7: .asciiz "	|-----|\n	|     |\n	O     |\n       \\|/    |\n	|     |\n       / \\    |\n	---------\n"

# current $t's being used as reference
# - $t7, used to store first user input string
.text
main:
	li $t4, 0	#correct counter
	li $t9, 0	#incorrect counter

wordChoice:
	#print rules and word request, take user string input
	defString(rules)
	defString(wordRequest)
	getUserInt
	move $t1, $t0
	
	#references wordbank
	beq $t1, 1, zebra
	beq $t1, 2, grade
	beq $t1, 3, ocean
	beq $t1, 4, laser
	beq $t1, 5, jerky

#wordbank	
zebra: 
	la $s2, wordBank1
	j menu
	
grade: 
	la $s2, wordBank2
	j menu
	
ocean: 
	la $s2, wordBank3
	j menu
	
laser: 
	la $s2, wordBank4
	j menu
	
jerky: 
	la $s2, wordBank5
	j menu

menu:	

	#stringTestCount
	li $t8, 1
	#set wordbank word
	move $t7, $s2
	
	defString(userMenu)
	defString(userChoice)
	getUserInt
	move $t5, $t0
	
	beq $t5, 1, playerGuess #moves player to guess
	beq $t5, 2, playerGuess #moves player to guess
	beq $t5, 3, wordChoice  #allows for new word to be chosen
	beq $t5, 4, exit	#exits the entire game
	
playerGuess:
	defString(userGuess)
	getInput
	
	beq $t9, 7, difString
	beq $t4, 5, sameString
	
	la $s1, userInput
	move $t3, $s1
	move $t6, $t1	#stores user guess into $t6
	beq $t5, 2, charCompare
	beq $t5, 1, stringCompareLoop
	
	
charCompare:
	
	lb $t0, 0($t7) #loads character of actual string on (first loop = first character)
	lb $t2, 0($t6) #loads character of guessed string on (first loop = first character)
	#breaks into equal solution if char matcges 
	beq $t0, $t2, sameChar	
	
	beq $t8, 6, wrongChar
	addi $t8, $t8, 1
	
	
	
	#points to next char
	addi $t7, $t7, 1
	#if whole string is does not match then character guess wrong
	j charCompare
	
sameChar:
	defString(correctCharacterGuess)
	
	
	j menu
wrongChar:
	defString(wrongCharacterGuess)
	#sub from a created counter for how many mistakes
	addi $t9, $t9, 1
	#break statement for if enough mistakes goes to you lose screen
	j menu
	
stringCompareLoop:
	
	lb $t3, ($t7) #loads character of actual string on (first loop = first character)
	lb $t2, ($t6) #loads character of guessed string on (first loop = first character)
	#checks if the characters are equal, if not equal sends to difString
	bne $t2, $t3, difString
	
	addi $t8, $t8, 1
	beq $t8, 6, sameString
	
	#points to next char
	addi $t7, $t7, 1
	addi $t6, $t6, 1
	j stringCompareLoop
		
difString:
	#if not then the string did not match have player guess again
	defString(wrongStringGuess)
	
	j exit

sameString: 
	#correct string guess move to menu for play again or exit
	defString(correctStringGuess)
	
	j exit


exit:
	defString(exitMessage)
	li $v0, 10
	syscall
