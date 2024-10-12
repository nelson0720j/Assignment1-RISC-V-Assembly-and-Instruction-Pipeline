    .data
test_value: 
    .word 0x00001000    # Test value

    .text
    .global _start

_start:
    # Load the test value
    la a0, test_value   # Load the address of the variable into a0
    lw a0, 0(a0)        # Load the value from the address into a0

    # Call my_clz function
    jal ra, my_clz      # Jump and link to my_clz, result will be in a0

    # Print the result
    li a7, 1            # Prepare for ecall to print integer
    ecall               # Print the result in a0

    # Exit the program
    li a7, 10           # Prepare for ecall to exit
    ecall

# Function to count leading zeros (CLZ)
my_clz:
    addi sp, sp, -24    # Reserve stack space
    sw ra, 20(sp)       # Save return address
    sw s0, 16(sp)       # Save s0
    sw s1, 12(sp)       # Save s1
    sw s2, 8(sp)        # Save s2
    sw s3, 4(sp)        # Save s3
    sw s4, 0(sp)        # Save s4

    li s0, 31           # Initialize s0 = 31 (index)
    li s1, 0            # Initialize s1 = 0 (count)

loop:
    li s4, 0x1          # Load 1 into s4
    sll s2, s4, s0      # Shift left 1 by s0 bits
    and s3, a0, s2      # Perform bitwise AND with a0 and s2
    bne s3, x0, done    # If the result is non-zero, branch to done

    addi s1, s1, 1      # Increment the count
    addi s0, s0, -1     # Decrement the index

    bge s0, x0, loop    # If s0 >= 0, continue looping

done:
    mv a0, s1           # Move the count (leading zeros) to a0
    lw ra, 20(sp)       # Restore return address
    lw s0, 16(sp)       # Restore s0
    lw s1, 12(sp)       # Restore s1
    lw s2, 8(sp)        # Restore s2
    lw s3, 4(sp)        # Restore s3
    lw s4, 0(sp)        # Restore s4
    addi sp, sp, 24     # Restore stack space
    ret                 # Return from function