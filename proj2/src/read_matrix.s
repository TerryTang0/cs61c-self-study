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
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    mv s1, a1   # s1 = a1; s1 stores the row pointer
    mv s2, a2   # s2 = a2; s2 stores the column pointer

    # Call fopen
    li a1, 0    # a1 = 0
    jal ra, fopen   # call fopen

    li t0, -1   # t0 = -1
    beq a0, t0, fopen_error
    mv s0, a0   # s0 = a0

    # Call fread. Retrieve the number of rows and columns
    # Read rows
    mv a0, s0
    mv a1, s1
    li a2, 4
    jal ra, fread   # do we need an 'end of file' label?
    li t0, 4    # t0 = 4
    bne a0, t0, fread_error
    lw s5, 0(s1)   # s5 = a0; s5 stores the number of rows in the matrix

    # Read columns
    mv a0, s0
    mv a1, s2
    li a2, 4
    jal ra, fread 
    li t0, 4
    bne a0, t0, fread_error
    lw s6, 0(s2)   # s6 = a0; s6 stores the number of columns in the matrix



    # Calculate the allocation
    mul s3, s5, s6  # s3 = s5 * s6
    slli s3, s3, 2   # s3 = s3 * 4; s3 store the number of bytes that we want to allocate

    # Call malloc. Make allocation
    mv a0, s3   # a0 = s3
    jal ra, malloc

    li t0, 0    # t0 = 0
    beq a0, t0, malloc_error
    mv s4, a0   # s4 = a0; s4 saves the pointer to allocated memory

    # Call fread. Read matrix
    mv a0, s0   # a0 = s0
    mv a1, s4   # a1 = s4
    mv a2, s3   # a2 = s3
    jal ra, fread

    # Restore registers after the next step
    bne a0, s3, fread_error

    # Call fclose
    mv a0, s0   # a0 = s0
    jal ra, fclose
    bne a0, x0, fclose_error



    # Epilogue
    mv a0, s4

    lw s6, 28(sp)
    lw s5, 24(sp)
    lw s4, 20(sp)
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 32
    
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


fclose_error:

    li a0, 28
    j exit