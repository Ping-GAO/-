# COMP1521 18s1 Week 05 Lab
#
# void multMatrices(int n, int m, int p,
#                   int A[n][m], int B[m][p], int C[n][p])
# {
#    for (int r = 0; r < n; r++) {
#       for (int c = 0; c < p; c++) {
#          int sum = 0;
#          for (int i = 0; i < m; i++) {
#             sum += A[r][i] * B[i][c];
#          }
#          C[r][c] = sum;
#       }
#    }
# }
   .data
   
   .text
   .globl multMatrices
multMatrices:
   # possible register usage:
   # n is $s0, m is $s1, p is $s2,
   # r is $s3, c is $s4, i is $s5, sum is $s6

   # set up stack frame for multMatrices()
   sw   $fp, -4($sp)
   la   $fp, -4($sp)
   sw   $ra, -4($fp) 
   sw   $s0, -8($fp)                      #  N
   sw   $s1, -12($fp)                     #  M
   sw   $s2, -16($fp)                     #  P

   sw   $s3, -20($fp)                     #  r
   sw $s4, -24($fp)                       #  c
   sw    $s5, -28($fp)                    #  i
   sw $s6, -32($fp)                       #  sum
   addi $sp, $sp, -36
   # implement above C code

   move $s0, $a0
   move $s1, $a1
   move $s2, $a2
   
   li $s3, 0

mult_loop1:
   bge $s3, $s0, mult_end1              # if (r >= N) break;
   li  $s4, 0
   mult_loop2:
      bge $s4, $s2, mult_end2
      li $s5, 0
      li $s6, 0                        # sum = 0

      mult_loop3:
         bge $s5, $s1, mult_end3      # if(i>=m) break;

         li $t1, 4
         li $t0, 0
         mul $t0, $s3, $s1             # r*ncols
         mul $t0, $t0, $t1
         mul $t1, $t1, $s5
         add $t0, $t0, $t1             # t0 has the offset 
         
         lw $t1, 12($fp)               # A[0][0]
         
        
         
         add $t0, $t0, $t1             # A[r][i]
         lw $t1, ($t0)                 # t1 = A[r][i] 
         
         #move $a0, $t1
         #li $v0,1
         #syscall
         #li $a0, '\n'
         #li $v0,11
         #syscall


         li $t3, 4
         li $t2, 0
         mul $t2, $s5, $s2             # i*ncols
         mul $t2, $t2, $t3             
         mul $t3, $t3, $s4               # c* 4
         add $t2, $t2, $t3            # t2 = offset 
         lw $t3, 8($fp)
         add $t2, $t2, $t3
         lw $t3, ($t2)                 # t3 = B[i][c]

         
         #move $a0, $t3
         #li $v0,1
         #syscall
         #li $a0, '\n'
         #li $v0,11
         #syscall
         
         
         mul $t2,$t1, $t3              # t2 =  A[r][i] * B[i][c]
         add $s6, $s6, $t2
         
         #move $a0, $s6
         #li $v0,1
         #syscall
         #li $a0, '\n'
         #li $v0,11
         #syscall



        
         addi $s5, $s5, 1
         j mult_loop3
      mult_end3:
                              
         li $t5, 4
         li $t4, 0                     
         mul $t4, $s3, $s2             # r*ncols
         mul $t4, $t4, $t5
         mul $t5, $t5, $s4
         add $t4, $t4, $t5            # t4 = offset
         lw $t5, 4($fp)
         add $t4, $t4,$t5
         
         #move $a0, $s6
         #li $v0,1
         #syscall
         #li $a0, '\n'
         #li $v0,11
         #syscall
         
        

         sw $s6, ($t4)  
         addi $s4, $s4, 1               # c++
         j mult_loop2
   addi $s4, $s4, 1
   j mult_loop2
   mult_end2:
      addi $s3, $s3, 1
      j mult_loop1


 mult_end1:

   lw   $ra, -4($fp)
   lw   $s0, -8($fp)
   lw   $s1, -12($fp)
   lw   $s2, -16($fp)
   lw   $s3, -20($fp)
   lw   $s4, -24($fp)
   lw   $s5, -28($fp)
   lw   $s6, -32($fp)
   la   $sp, 4($fp)
   lw   $fp, ($fp)
   jr   $ra



   # clean up stack and return