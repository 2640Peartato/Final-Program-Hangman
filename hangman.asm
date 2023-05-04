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
la $a1, 63
syscall
#move content in buffer to another register
move $t1, $a0
.end_macro

.data
userInput: .space 51 #string length max is 50 chars
rules: .asciiz "\nChoose a word, you will have 5 attempts to get the word before you lose."
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
wordBank5: .asciiz "valve"

# current $t's being used as reference
# - $t7, used to store first user input string
.text
main:

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
	beq $t1, 5, valve

#wordbank	
zebra: 
	la $t7, wordBank1
	j menu
	
grade: 
	la $t7, wordBank2
	j menu
	
ocean: 
	la $t7, wordBank3
	j menu
	
laser: 
	la $t7, wordBank4
	j menu
	
valve: 
	la $t7, wordBank5
	j menu

menu:	
	defString(userMenu)
	defString(userChoice)
	getInput
	move $t5, $t1
	
	beq $t5, 1, playerGuess #moves player to guess
	beq $t5, 2, playerGuess #moves player to guess
	beq $t5, 3, wordChoice  #allows for new word to be chosen
	beq $t5, 4, exit	#exits the entire game 
	
playerGuess:
	defString(userGuess)
	getInput
	move $t6, $t1	#stores user guess into $t6
	beq $t5, 1, charCompare
	beq $t5, 2, stringCompareLoop
	
charCompare:
	lb $t0, 0($t7) #loads character of actual string on (first loop = first character)
	lb $t2, 0($t6) #loads character of guessed string on (first loop = first character)
	#checks if the characters are equal, if 0 then equal
	sub $t3, $t2, $t0
	#breaks into equal solution if char matcges 
	beq $t3, 0, sameChar
	j wrongChar
	
sameChar:
	defString(correctCharacterGuess)
	j menu
wrongChar:
	defString(wrongCharacterGuess)
	#sub from a created counter for how many mistakes
	#break statement for if enough mistakes goes to you lose screen
	j menu
	
stringCompareLoop:
	lb $t0, 0($t7) #loads character of actual string on (first loop = first character)
	lb $t2, 0($t6) #loads character of guessed string on (first loop = first character)
	#checks if the characters are equal, if 0 then equal
	sub $t3, $t2, $t0
	
	#moves into iterating to next character if characters checked are euqal
	beq $t3, 0, equalLoop
	#if not equal then moves into the ending of the loop
	j stringEnd

equalLoop:
	beq $t2, 5, stringEnd
	#iterates to next character in strings
	addi $t7, $t7, 1
	addi $t6, $t6, 1
	j stringCompareLoop
		
stringEnd:
	#if the string is the same
	beq $t6, $zero, sameString
	#if not then the string did not match have player guess agai
	defString(wrongStringGuess)
	#wrong string guess game over
	j menu

sameString: 
	#correct string guess move to menu for play again or exit
	defString(correctStringGuess)
	j menu

exit:
	defString(exitMessage)
	li $v0, 10
	syscall
