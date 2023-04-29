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
userMenu: .asciiz "\nPlease enter a number to choose an option\n(1) guess word\n(2) guess a letter\n(3) give up"


# current $t's being used as reference
# - $t7, used to store first user input string
.text
main:
	#print rules and word request, take user string input
	defString(rules)
	defString(wordRequest)
	getInput
	move $t7, $t1 #stores user inputed string into $t7
	
	
	defString(userMenu)
exit:
	li $v0, 10
	syscall
