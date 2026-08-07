.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    mv s1, a1   # s1 = a1; s1 stores the address of the matrix
    mv s2, a2   # s2 = a2; s2 stores the number of rows in the matrix
    mv s3, a3   # s3 = a3; s3 stores the number of columns in the matrix

    # Call fopen
    li a1, 1
    jal ra, fopen

    li t0, -1
    beq a0, t0, fopen_error
    mv s0, a0   # s0 = a0; s0 stores file descriptor

    # Call fwrite. Write the number of rows
    mv a0, s0
    addi sp, sp -4
    sw s2, 0(sp)

    mv a1, sp
    li a2, 1
    li a3, 4
    jal ra, fwrite
    li t0, 1
    bne a0, t0, fwrite_error

    lw s2, 0(sp)
    addi sp, sp, 4


    # Call fwrite. Write the number of columns
    mv a0, s0
    addi sp, sp -4
    sw s3, 0(sp)

    mv a1, sp
    li a2, 1
    li a3, 4
    jal ra, fwrite
    li t0, 1
    bne a0, t0, fwrite_error

    lw s3, 0(sp)
    addi sp, sp, 4

    # Call fwrite. Write the data to the file
    mv a0, s0
    mv a1, s1
    mul a2, s2, s3
    li a3, 4

    addi sp, sp, -4
    sw a2, 0(sp)

    jal ra, fwrite
    
    lw a2, 0(sp)
    addi sp, sp, 4
    bne a0, a2, fwrite_error

    # Call fclose
    mv a0, s0
    jal ra, fclose
    bne a0, x0, fclose_error




    # Epilogue
    lw s3, 16(sp)
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 20

    jr ra


fopen_error:

    li a0, 27
    j exit


fwrite_error:

    li a0, 30
    j exit


fclose_error:

    li a0, 28
    j exit