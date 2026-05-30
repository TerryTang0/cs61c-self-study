.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)
    mv t0, a0    # Copy the start of array to register t0
    mv t1, a1    # Copy the length of the array to register t1
    li t2, 0    # Initialize the counter to 0
    li t3, 1    # t3 = 1
    blt a1, t3, loop_error

loop_start:
    bge t2, a1, loop_end
    lw t4 0(t0)    # t4 = arr[i]
    bge t4, x0, loop_continue
    sw x0, 0(t0)    # set the negative value to 0




loop_continue:
    addi t0, t0, 4
    addi t2, t2, 1
    j loop_start


loop_error:
    li a0, 36
    j exit


loop_end:


    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4

    jr ra
