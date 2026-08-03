.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    bge x0, a1, error    # If 0 >= a1, go to error
    bge x0, a2, error    # If 0 >= a2, go to error
    bge x0, a4, error    # If 0 >= a4, go to error
    bge x0, a5, error    # If 0 >= a5, go to error
    bne a2, a4, error    # If a2 != a4, go to error


    # Prologue
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    
    li s1, 0    # Initialize the number of row in matrix A
    li s2, 0    # Initialize the number of column in matrix B
    li t2, 0    # t2 = 0; store address of array in matrix A 
    li t3, 0    # t3 = 0; store address of array in matrix B
    


outer_loop_start:
 
    li s2, 0     # Reset s2

    bge s1, a1, outer_loop_end

    # update the address of the first elements in the target row in matrix A into t2
    add t2, x0, s1    # t2 = x0 + s1
    mul t2, t2, a2    # t2 = t2 + a2
    slli t2, t2, 2    # t2 = t2 * 4
    add t2, t2, a0    # t2 = t2 + a0

    j inner_loop_start    # Not sure if I should use j or jal here. Need to check



inner_loop_start:

    bge s2, a5, inner_loop_end    # If s2 >= a5, go to inner_loop_end

    add t3, x0, s2    # t3 = s2
    slli t3, t3, 2    # t3 = t3 * 4
    add t3, t3, a3    # t3 = t3 + a3


    # Set calling convention for register a0~a6
    addi sp, sp, -40
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw t2, 28(sp)
    sw t3, 32(sp)
    sw t4, 36(sp)

    mv a0, t2    # Move t2 to a0
    mv a1, t3    # Move t3 to a1
    li a3, 1    # a3 = 1
    mv a4, a5    # Move a5 to a4; In second matrix, stride = width

    jal ra, dot    # Call dot.s

    mv t6, a0    # t6 = a0

    lw t4, 36(sp)
    lw t3, 32(sp)
    lw t2, 28(sp)
    lw a6, 24(sp)
    lw a5, 20(sp)
    lw a4, 16(sp)
    lw a3, 12(sp)
    lw a2, 8(sp)
    lw a1, 4(sp)
    lw a0, 0(sp)
    addi sp, sp, 40

    mul t5, s1, a5    # t5 = s1 * a2
    add t5, t5, s2    # t5 = t5 + s2
    slli t5, t5, 2    # t5 = t5 * 4

    add t5, t5, a6    # t5 = t5 + a6; t5 is the address to store the product
    sw t6, 0(t5)

    addi s2, s2, 1    # Increment the column by 1

    j inner_loop_start


inner_loop_end:


    j outer_loop_repeat


outer_loop_repeat:

    addi s1, s1, 1
    j outer_loop_start


outer_loop_end:


    # Epilogue
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 12


    jr ra



error:
    li a0, 38
    j exit