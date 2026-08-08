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
    addi sp, sp, 

    mv s0, a0   # s0 = a0
    mv s1, a1   # s1 = a0; s1 stores the pointer to an array of argument strings

    # Read pretrained m0
    lw a0, 4(s1)    # Load pointer to the filepath of m0 to a0
    addi sp, sp, -20
    addi a1, sp, 0
    addi a2, sp, 4

    jal ra, read_matrix

    mv s2, a0   # s2 = a0; s2 store the pointer to m0 in the memory


    # Read pretrained m1
    lw a0, 8(s1)    #Load pointer to the file path of m1 to a0
    addi a1, sp, 8
    addi a2, sp, 12

    jal ra, read_matrix

    mv s3, a0   # s3 = a0; s3 stores the pointer to m1 in the memory



    # Read input matrix
    lw a0, 12(s1)    #Load pointer to the file path of m1 to a0
    addi a1, sp, 16
    addi a2, sp, 20

    jal ra, read_matrix

    mv s4, a0   # s4 = a0; s4 stores the pointer to m1 in the memory


    # Compute h = matmul(m0, input)


    # Compute h = relu(h)


    # Compute o = matmul(m1, h)


    # Write output matrix o


    # Compute and return argmax(o)


    # If enabled, print argmax(o) and newline


    jr ra
