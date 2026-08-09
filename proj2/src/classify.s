.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:

    # Prologue
    addi sp, sp, -64
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)

    mv s0, a0   # s0 = a0
    mv s1, a1   # s1 = a0; s1 stores the pointer to an array of argument strings
    mv s8, a2   # s8 = a2; s2 stores the print argument

    li t0, 5
    bne a0, t0, argument_error

    # Read pretrained m0
    lw a0, 4(s1)    # Load pointer to the filepath of m0 to a0
    addi a1, sp, 40     # 40(sp) stores the number of rows in m0
    addi a2, sp, 44     # 44(sp) stores the number of cols in m0

    jal ra, read_matrix

    mv s2, a0   # s2 = a0; s2 store the pointer to m0 in the memory


    # Read pretrained m1
    lw a0, 8(s1)    # Load pointer to the file path of m1 to a0
    addi a1, sp, 48     # 48(sp) stores the number of rows in m1
    addi a2, sp, 52     # 52(sp) stores the number of cols in m1

    jal ra, read_matrix

    mv s3, a0   # s3 = a0; s3 stores the pointer to m1 in the memory



    # Read input matrix
    lw a0, 12(s1)    # Load pointer to the file path of input matrix to a0
    addi a1, sp, 56     # 56(sp) stores the number of rows in input matrix
    addi a2, sp, 60     # 60(sp) stores the number of cols in input matrix

    jal ra, read_matrix

    mv s4, a0   # s4 = a0; s4 stores the pointer to input matrix in the memory


    # Compute h = matmul(m0, input)

    # Calculate allocation space
    lw t0, 40(sp)
    lw t1, 60(sp)
    mul a0, t0, t1
    slli a0, a0, 2

    # Make allocation
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s5, a0   # s5 = a0; s5 stores the pointer to the matrix h

    # Call matmul
    mv a0, s2
    lw a1, 40(sp)
    lw a2, 44(sp)
    mv a3, s4
    lw a4, 56(sp)
    lw a5, 60(sp)
    mv a6, s5

    jal ra, matmul
    


    # Compute h = relu(h)
    mv a0, s5
    lw t0, 40(sp)
    lw t1, 60(sp)
    mul a1, t0, t1

    jal ra, relu



    # Compute o = matmul(m1, h)
    # Make allocation for o
    lw t0, 48(sp)
    lw t1, 60(sp)
    mul a0, t0, t1
    slli a0, a0, 2
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s6, a0   # s6 = a0; s6 stores the pointer to matrix o

    ## Call matmul for o = matmul(m1, h)
    mv a0, s3
    lw a1, 48(sp)
    lw a2, 52(sp)
    mv a3, s5
    lw a4, 40(sp)
    lw a5, 60(sp)
    mv a6, s6
    jal ra, matmul

    

    # Write output matrix o
    lw a0, 16(s1)   
    mv a1, s6
    lw a2, 48(sp)
    lw a3, 60(sp)
    jal ra, write_matrix



    # Compute and return argmax(o)
    mv a0, s6
    lw t0, 48(sp)
    lw t1, 60(sp)
    mul a1, t0, t1
    jal ra, argmax
    mv s7, a0   # s7 = a0; s7 stores the largest element


    bne s8, x0, classify_end


argmax_print:

    # If enabled, print argmax(o) and newline
    jal ra, print_int

    li a0, 10   # Use ASCII code 10 to print '\n'
    jal ra, print_char




classify_end:

    # Call free. Free allocation
    mv a0, s2
    jal ra, free

    mv a0, s3
    jal ra, free
    
    mv a0, s4
    jal ra, free

    mv a0, s5
    jal ra, free

    mv a0, s6
    jal ra, free


    mv a0, s7   # return a0


    # Epilogue
    lw s8, 36(sp)
    lw s7, 32(sp)
    lw s6, 28(sp)
    lw s5, 24(sp)
    lw s4, 20(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 64


    jr ra


argument_error:
    li a0, 31
    j exit



malloc_error:

    li a0, 26
    j exit