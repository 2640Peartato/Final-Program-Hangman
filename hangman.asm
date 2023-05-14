#Names: Catalina Davis, Kenneth Hung, Ayanna Sanges-Chu
#Date: 05/14/23
#Objectives: Create a Hangman game
# - print rules to user
# - pull from a wordbank for the word used in the game
# - 4 options for the user
#   - guess word, if correct instant win, else add 1 to counter
#	- if incorrect, instant loss
#   - guess character, if correct display char locations, else add 1 to counter
#	- if incorrect, add 1 to incorrect counter, display ascii art of hangman
#   - give up, game end, jump back to wordChoice
#   - exit program

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
rules: .asciiz "\nChoose a word, you have 1 chance to guess a word, and 6 possible strikes when choosing a letter.\nIf you guess the wrong word, or choose 5 letters not in the word you lose."
wordRequest: .asciiz "\nSelect an int (1-5) and a word will be provided for the game: "
userMenu: .asciiz "\n~~~~~~~~~~~~~~Main Menu~~~~~~~~~~~~~~\n(1) guess word\n(2) guess a letter\n(3) give up\n(4) exit the game"
userChoice: .asciiz "\nPlease enter a number to choose an option: "
userGuess: .asciiz "\nEnter your guess: "
correctCharacterGuess:"\nCorrect letter!"
wrongCharacterGuess:"\nSorry wrong letter"
correctStringGuess:"\nCongratulations you guessed the correct word!"
wrongStringGuess:"\nIncorrect guess of the word"
exitMessage: .asciiz "\nThanks for playing!"
letterPlace1: .asciiz "\nIn this 5 letter word, the letter you entered is the first letter."
letterPlace2: .asciiz "\nIn this 5 letter word, the letter you entered is the second letter."
letterPlace3: .asciiz "\nIn this 5 letter word, the letter you entered is the third letter."
letterPlace4: .asciiz "\nIn this 5 letter word, the letter you entered is the fourth letter."
letterPlace5: .asciiz "\nIn this 5 letter word, the letter you entered is the fifth letter."
wordBank1: .asciiz "zebra"
wordBank2: .asciiz "grade"
wordBank3: .asciiz "ocean"
wordBank4: .asciiz "laser"
wordBank5: .asciiz "jerky"
test: .asciiz "\ntest"
invalid: .asciiz "\nInvalid input, try again!"

#ascii art:
life2: .asciiz "\n	|-----|\n	|     |\n	O     |\n	      |\n	      |\n	      |\n	---------\n"
life3: .asciiz "\n	|-----|\n	|     |\n	O     |\n	|     |\n	|     |\n	      |\n	---------\n"
life4: .asciiz "\n	|-----|\n	|     |\n	O     |\n       \\|     |\n	|     |\n	      |\n	---------\n"
life5: .asciiz "\n	|-----|\n	|     |\n	O     |\n       \\|/    |\n	|     |\n	      |\n	---------\n"
life6: .asciiz "\n	|-----|\n	|     |\n	O     |\n       \\|/    |\n	|     |\n       /      |\n	---------\n"
life7: .asciiz "\n	|-----|\n	|     |\n	O     |\n       \\|/    |\n	|     |\n       / \\    |\n	---------\n	GAME OVER\n"


# current $t's being used as reference
# - $t7 and $s2, used to store first user input string
# - $t8, counter for comparison loops

.text
main:
wordChoice:
	li $t4, 0	#correct counter
	li $t9, 0	#incorrect counter
	
	#print rules and word request, take user string input
	defString(rules)
	defString(wordRequest)
	getUserInt
	move $t1, $t0
	
	#references wordbank
	ble $t0, 0, INVALID
	beq $t1, 1, zebra
	beq $t1, 2, grade
	beq $t1, 3, ocean
	beq $t1, 4, laser
	beq $t1, 5, jerky
	bge $t1, 6, INVALID
	
#wordbank
# sets word as chosen by the user and then jumps to menu (zebra-jerky) +INVALID for error handling	
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

#for non wordbank number inputs
INVALID:
	defString(invalid)
	j wordChoice

menu:	
	#stringTestCount
	li $t8, 1
	#set wordbank word
	move $t7, $s2
	
	#prints out menu that contains user options and prompt for user input 
	defString(userMenu)
	defString(userChoice)
	getUserInt
	move $t5, $t0
	
	#branch statements to check for invalid inputs as well as player choice
	ble $t5, 0, inval
	beq $t5, 1, playerGuess #moves player to guess
	beq $t5, 2, playerGuess #moves player to guess
	beq $t5, 3, wordChoice  #allows for new word to be chosen
	beq $t5, 4, exit	#exits the entire game
	bge $t5, 5, inval

#handles invalid inputs
inval:
	defString(invalid)
	j menu

#takes in player guess sends to charCompare or stringCompareLoop based on $t5
playerGuess:
	#prints prompt to take user guess
	defString(userGuess)
	getInput
	
	#checks correct and incorrect counters
	beq $t9, 7, difString
	beq $t4, 4, sameString
	
	move $t6, $t1	#stores user guess into $t6
	
	#sends to corresponding label depending on user choice in menu
	beq $t5, 2, charCompare
	beq $t5, 1, stringCompareLoop
	
charCompare:
	lb $t0, 0($t7) #loads character of actual string on (first loop = first character)
	lb $t2, 0($t6) #loads character of guessed string on (first loop = first character)
	#breaks into equal solution if char matches 
	beq $t0, $t2, letterPlacement	
	beq $t8, 6, wrongChar
	addi $t8, $t8, 1
	#points to next char
	addi $t7, $t7, 1
	#if whole string is does not match then character guess wrong
	j charCompare
	
letterPlacement:
	#based on $t8, the letter will be found at the corresponding number
	# ex. 'zebra', if user guesses 'b' $t8 should end up being 3
	# Branch statements to labels that will print the corresponding place of user guessed letter
	beq $t8, 1, place1
	beq $t8, 2, place2
	beq $t8, 3, place3
	beq $t8, 4, place4
	beq $t8, 5, place5
	beq $t8, 6, place5

# labels (place1-place5) correspond to the letter placement within a word
place1:
	defString(letterPlace1)
	j sameChar
	
place2:
	defString(letterPlace2)
	j sameChar
	
place3:
	defString(letterPlace3)
	j sameChar
	
place4:
	defString(letterPlace4)
	j sameChar
	
place5:
	defString(letterPlace5)
	j sameChar

#if the guessed letter corresponds to a letter within the word, declare it to the user, add to correct counter, and jump back to menu	
sameChar:
	defString(correctCharacterGuess)
	addi $t4, $t4, 1
	j menu

#if guessed letter is not in the word, declare to user, add to incorrect counter, branch to hangman ascii art
wrongChar:
	defString(wrongCharacterGuess)
	#sub from a created counter for how many mistakes
	addi $t9, $t9, 1
	
	beq $t9, 1, live2
	beq $t9, 2, live3
	beq $t9, 3, live4
	beq $t9, 4, live5
	beq $t9, 5, live6
	beq $t9, 6, difString
	
	#break statement for if enough mistakes goes to you lose screen
	#j menu

#corresponding labels to print ascii art at corresponding amount of failures (live2-live6)
live2:
	defString(life2)
	
	j menu
live3:
	defString(life3)
	
	j menu
live4: 
	defString(life4)
	
	j menu
live5:
	defString(life5)
	
	j menu
live6:
	defString(life6)
	
	j menu	

#compares the string given by user and actual word
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

#for when user inputed string is not the same, declare to user, show game over, send back to wordchoice	
difString:
	#if not then the string did not match have player guess again
	defString(wrongStringGuess)
	defString(life7)
	j wordChoice

#for when user correctly guessed word, declare contratulations to user, send back to wordchoice
sameString: 
	#correct string guess move to menu for play again or exit
	defString(correctStringGuess)
	j wordChoice

exit:
	#ends the program
	defString(exitMessage)
	li $v0, 10
	syscall
