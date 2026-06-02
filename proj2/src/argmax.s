.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi sp, sp, -4
    sw ra, 0(sp)
    mv t0, a0    # t0 = a0
    li t1, 0    # t1 is the increment of the loop
    li t2, 0    # t2 save the index of max element
    lw t3, 0(a0)    # t3 keep the largest element

loop_start:
    bge x0, a1, loop_error
    bge t1, a1, loop_end
    lw t4, 0(t0)    # Load the element to be checked to t4
    bge t3, t4, loop_continue
    mv t4, t3    # Update the max element
    mv t1, t2    # Update the index of max element
    
loop_error:
    li a0, 36
    j exit

loop_continue:
    addi t0, t0, 4
    addi t1, t1, 1

loop_end:
    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4
    mv t2, a0
    jr ra
