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
      
     invalidMessage:
      li $v0, 0
      la $t0, invalid   #load message to print for invalid input

