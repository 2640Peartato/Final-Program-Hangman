#Names: Catalina Davis, Kenneth Hung, Ayanna Sanges-Chu
#Date: 05/14/23
#Objectives: Create a Hangman game
# - print rules to user
# - get user string input for word used in game, possibly need to get string length
# - 3 options for the user
#   - guess word, if correct instant win, else add 1 to counter
#   - guess character, if correct display char locations, else add 1 to counter
#   - give up, haha loser, game end

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
rules: .asciiz "\nProvide a word, you will have 5 attempts to get the word before you lose."
wordRequest: .asciiz "\nPlease provide a word (50 character limit): "
userMenu: .asciiz "\n~~~~~~~~~~~~~~Main Menu~~~~~~~~~~~~~~\n(1) guess word\n(2) guess a letter\n(3) give up\n(4) exit the game"
userChoice: .asciiz "\nPlease enter a number to choose an option: "
userGuess: .asciiz "\nEnter your guess: "
correctCharacterGuess:"\nCorrect letter!"
wrongCharacterGuess:"\nSorry wrong letter"
correctStringGuess:"\nCongratulations you guessed the correct word!"
wrongStringGuess:"\nIncorrect guess of the word"
exitMessage: .asciiz "\nThanks for playing!"

# current $t's being used as reference
# - $t7, used to store first user input string
.text
main:

wordChoice:
	#print rules and word request, take user string input
	defString(rules)
	defString(wordRequest)
	getInput
	move $t7, $t1 #stores user inputed string into $t7
	
menu:	
	defString(userMenu)
	defString(userChoice)
	getInput
	
	beq $t1, 1, playerGuess #moves player to guess
	beq $t1, 2, playerGuess #moves player to guess
	beq $t1, 3, wordChoice  #allows for new word to be chosen
	beq $t1, 4, exit	#exits the entire game 
	
playerGuess:
	defString(userGuess)
	getInput
	move $t6, $t1	#stores user guess into $t6
	
compareLoop:
	lb $t0, 0($t7) #loads character of actual string on (first loop = first character)
	lb $t2, 0($t6) #loads character of guessed string on (first loop = first character)
	#checks if the characters are equal, if 0 then equal
	sub $t3, $t2, $t0
	
	#moves into iterating to next character if characters checked are euqal
	beq $t3, 0, equalLoop
	#if not equal then moves into the ending of the loop
	j endLoop

equalLoop:
	
	#iterates to next character in strings
	addi $t7, $t7, 1
	addi $t6, $t6, 1
	j compareLoop
	
endLoop:
	
	
exit:
	defString(exitMessage)
	li $v0, 10
	syscall
