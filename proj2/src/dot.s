.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)

    bge x0, a2, loop_error36
    bge x0, a3, loop_error37
    bge x0, a4, loop_error37

    li t2, 0    # t2 = 0; t2 is the index of pair
    li t3, 0    # t3 = 0
    li t4, 0    # t4 = 0


loop_start:

    bge t2, a2, loop_end    # if t2 = a2, goto loop_end

    mul t0, t2, a3    # t0 = t2 * a3
    slli t0, t0, 2    # t0 = t0 * 4; now t0 contains the offset now
    add t0, t0, a0    # t0 = t0 + a0; t0 is the address of the element need to 
                      # be calculated in first array
    mul t1, t2, a4    # t1 = t2 * a4
    slli t1, t1, 2    # t1 = t1 * 4
    add t1, t1, a1    # t1 = t1 + a1; t1 is the address of the element need to 
                      # be calculated in second array
    
    lw t0, 0(t0)    # Load the element value into t0
    lw t1, 0(t1)    # Load the element value into t1

    mul t3, t0, t1    # t3 = t0 * t1
    add t4, t4, t3    # t4 = t4 + t3; t4 is the sum of dots

    addi t2, t2, 1    # Increment of 1 on t2

    j loop_start



loop_end:

    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4

    mv a0, t4   # a0 = t4

    jr ra


loop_error36:

    li a0, 36
    j exit


loop_error37:

    li a0, 37
    j exit