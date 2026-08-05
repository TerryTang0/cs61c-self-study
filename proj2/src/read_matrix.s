.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue

    mv s1, a1   # s1 = a1
    mv s2, a2   # s2 = a2

    # Call fopen
    jal ra, fopen   # call fopen

    li t0, -1   # t0 = -1
    li a1, 0    # a1 = 0; need to confirm
    beq a0, t0, fopen_error
    mv s0, a0   # s0 = a0

    # Calculate the allocation
    li t1, 0    # t0 = 1
    lw t1, 0(s1)    # t1 store the number of rows
    lw t2, 0(s2)    # t2 store the number of columns
    mul t1, t1, t2  # t1 = t1 * t2
    slli s3, t1, 2   # s3 = t1 * 4

    # Call malloc. Make allocation
    mv a0, t1   # a0 = t1
    jal ra, malloc

    li t0, 0    # t0 = 0
    beq a0, t0, malloc_error
    mv s4, a0   # s4 = a0; s3 saves pointer to the allocated memory

    # Call fread. Read matrix
    mv a0, s0   # a0 = s0
    mv a1, s4   # a1 = s4
    mv a2, s3   # a2 = s3
    jal ra, fread

    # Restore registers after the next step
    bne a0, s3, fread_error
    







    # Epilogue


    jr ra


fopen_error:

    li a0, 27
    j exit


malloc_error:

    li a0, 26
    j exit


fread_error:

    li a0, 29
    j exit