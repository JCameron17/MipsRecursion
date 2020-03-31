.data
  myString: .space 1000
  invalid: .asciiz "Invalid input"

.text
main:
    addi $t9, $zero, 31
    li $v0, 8
    la $a0, myString  #ask for user input
    li $a1, 101      #allocate space for input
    syscall
    
    #get input ready to split substrings and calculate decimal
    la $s2, myString  #move string to $s2 register
    li $s0, 0
    li $s1, 0
    
    loadSubstrings:
      la $s0, ($s1)   #substrings
      
     newSub:
      add $t4, $s2, $s1 	     #increment through string
      lb $t3, 0($t4) 		       #get character
      beq $t3, 0, handleInput  #leave newSub if null
      beq $t3, 10, handleInput #leave newSub if newline
      
     invalidMessage:
      li $v0, 0
      la $t0, invalid   #load message to print for invalid input
      
       decideLoop:
      blt $a0, 48, notAccepted  #character with ascii value < 48 is not accepted
      addi $v1, $0, 48          #value to be subtracted in multVal
      blt $a0, 58, Accepted     #accept digits
      blt $a0, 65, notAccepted  #special characters not accepted
      addi $v1, $0, 55          #value to be subtracted in multVal
    	blt $a0, 87, Accepted     #accept chars a-v
      blt $a0, 97, notAccepted  #do not accept special characters
      addi $v1, $0, 87          #value to be subtracted in multVal
      blt $a0, 119, Accepted     #accept characters a-v
      bgt $a0, 118, notAccepted     #characters above V not accepted
      
      Accepted:
      li $v0, 1         #print integer
      jr $ra

    notAccepted:
      li $v0, 0
      jr $ra



