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
      beq $t3, 44, handleInput #leave newSub if comma
      add $s1, $s1, 1
      j newSub

      handleInput:
        la $a0, ($s0)
        la $a1, ($s1)
        jal takeInput
        jal callNested
        beq $t3, 0, exit        #exit loops if null
        beq $t3, 10, exit       #exit loops if newline
        addi $s1, $s1, 1

        li $v0, 11              #instruction to print character
        li $a0, 44              #print comma
        syscall
        j loadSubstrings
        
        exit:
        li $v0, 10
        syscall

    takeInput:
      la $s3, ($ra)	      #jump to address in $ra when subprogram finishes
      la $t0, ($a0)	      #load value from $a0 to $t0
      addi $t1, $a1, 0    #store end of user input string
      la $t2, myString   #load beginning of user input string

    removeLeading:
      beq $t0, $t1, stringStart   #when to start processing string (no longer spaces)
      add $t5, $t2, $t0
      lb $t7, ($t5)
      beq $t7, 32, removeL        #if space char, remove
      beq $t7, 9, removeL         #if tab char, remove
      j removeFollowing
      
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



