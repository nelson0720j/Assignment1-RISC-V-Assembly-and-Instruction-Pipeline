    .data
input_val: 
    .word 0b00000000000000000000000010011100    # Example input value

    .text
    .global _start

_start:
    # Load the input value
    la a0, input_val    # Load address of input_val into a0
    lw a0, 0(a0)        # Load the value at input_val into a0 (n)

    # Call reverseBits function
    jal ra, reverseBits # Call reverseBits, result will be in a0

    # Print the result
    li a7, 1            # Syscall code for print integer
    ecall               # Print the result in a0

    # Exit the program
    li a7, 10           # Syscall code for exit
    ecall

# reverseBits function
reverseBits:
    addi sp, sp, -16    # Reserve stack space
    sw ra, 12(sp)       # Save return address
    sw t0, 8(sp)        # Save t0
    sw t1, 4(sp)        # Save t1
    sw t2, 0(sp)        # Save t2

    li t0, 0            # Initialize result = 0
    li t1, 32           # Initialize counter = 32

loop:
    beqz t1, done       # If counter == 0, exit loop

    slli t0, t0, 1      # result <<= 1
    andi t2, a0, 1      # Extract the least significant bit (n & 1)
    or t0, t0, t2       # result |= (n & 1)
    srli a0, a0, 1      # n >>= 1
    addi t1, t1, -1     # Decrement counter

    j loop              # Repeat the loop

done:
    mv a0, t0           # Move the result to a0 (return value)
    lw ra, 12(sp)       # Restore return address
    lw t0, 8(sp)        # Restore t0
    lw t1, 4(sp)        # Restore t1
    lw t2, 0(sp)        # Restore t2
    addi sp, sp, 16     # Restore stack space
    ret                 # Return from function