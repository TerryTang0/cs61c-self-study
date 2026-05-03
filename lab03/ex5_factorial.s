.globl factorial

.data
n: .word 7

.text
# Don't worry about understanding the code in main
# You'll learn more about function calls in lecture soon
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

# factorial takes one argument:
# a0 contains the number which we want to compute the factorial of
# The return value should be stored in a0
factorial:
    # YOUR CODE HERE
    addi t1 x0 1     # Initialize the increment t1
    li t2 1     # Initialize t2
    
Loop:
    blt a0 t1 End    # Set the termination
    mul t2 t2 t1     # t2 = t2 * t1
    addi t1 t1 1     # Increment t1 of 1
    j Loop
    
# All the comment in this part are my initial attempt to gather every thing in factorial function. Not working
#     addi t1 x0 1    # Initialize the increment
#     li t3 0     # Initialize t3
#     mul t3 t3 t1    # t3 = t3 * t1
#     addi t1 t1 1    # Increment the factor of 1
#     bge a0 t1 factorial   # Go to factorial if t1<t0
#     add a0 x0 t3    # Move the final answer to a0
#     add ra t3 x0    # Return final answer to ra
    
End:
    # This is how you return from a function. You'll learn more about this later.
    add a0 x0 t2     # Pass the result to a0
    # This should be the last line in your program.
    jr ra

# Finished testing. All the output returned from my functions are correct. 0! = 1, 3! = 6, 7! = 5040 and 8! = 40320.
