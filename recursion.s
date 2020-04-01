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
      
      removeL:
      addi $t0, $t0, 1            #move forward in string
      j removeLeading

    removeFollowing:
      beq $t0, $t1, stringStart   #when to start processing string (no longer spaces)
      add $t5, $t2, $t1
      addi $t5, $t5, -1
      lb $t7, ($t5)
      beq $t7, 32, removeF        #if space char, remove
      beq $t7, 9, removeF         #if tab char, remove
      j stringStart
      
      removeF:
        addi $t1, $t1, -1            #move forward in string
        j removeFollowing

    stringStart:
      beq $t0, $t1, invalidMessage  #empty string prompts invalid message
      li $t6, 0 				            #end of spaces
      li $s4, 0 				            #amount of chars
      
      preMult:
      beq $t0, $t1, over    #if end address equals start address end loop
      add $t5, $t2, $t0
      lb $t7, ($t5)
      la $a0, ($t7)
      jal decideLoop
      bne $v0, 0, multVal
      j invalidMessage

    multVal:
      mul $t6, $t6, $t9            #multiply by base
      sub $t5, $t7, $v1             #subtract based on value stored in decideLoop
      add $t6, $t6, $t5             #add decimal value to base
      addi $s4, $s4, 1              #increment
      addi $t0, $t0, 1              #increment
      j preMult
      
      over:
      bgt $s4, 20, invalid1	#do not accept strings over 20 chars
      li $v0, 1
      j finally
      
      invalid1:
        li $v0, 0
        la $t6, invalid
        j finally
      
     invalidMessage:
      li $v0, 0
      la $t0, invalid   #load message to print for invalid input
      
      finally:
      addi $sp, $sp, -4   #save value to stack
      sw $t6, ($sp)
      addi $sp, $sp, -4   #save value to stack
      sw $v0, ($sp)
      la $ra, ($s3)
      jr $ra
      
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
      
   
      callNested:  #call nested subroutines
    	   lw $t1, ($sp)
    	   addi $sp, $sp, 4
    	   lw $t2, ($sp)
    	   beq $t1, 0, invalid2 #empty string is invalid
         li $t5, 10
         divu $t2, $t5        #divide to prevent stack overflow
         li $v0, 1
     		 mflo $a0
     		 beq $a0, 0, dontPrint #keep program from printing early
         syscall
         
         dontPrint:
      	mfhi $a0
      	syscall
      	j return

        invalid2:
   li $v0, 4
   la $a0, ($t2)
   syscall

        return:
        jr $ra



