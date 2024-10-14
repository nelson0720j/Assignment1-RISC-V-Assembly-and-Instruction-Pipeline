.data
input_val: 
    .word 0b00000010100101000001111010011100    # Example input value
reverse_table:
    .byte 0, 8, 4, 12, 2, 10, 6, 14
    .byte 1, 9, 5, 13, 3, 11, 7, 15
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
    # Save registers
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s0, 20(sp)
    sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
    sw s4, 4(sp)
    sw s5, 0(sp)

    mv s0, a0               # s0 = n

    # Call the optimized my_clz
    jal ra, my_clz
    mv s1, a0               # s1 = leadingZeros

    li s2, 32
    sub s3, s2, s1          # s3 = effectiveBits = 32 - leadingZeros

    li s2, 0                # s2 = result = 0
    mv a0, s0               # Restore a0 = n

    beqz s3, reverse_done   # If effective bits are zero, skip the loop

    # Calculate the number of iterations (process 4 bits at a time)
    addi s5, s3, 3
    srli s5, s5, 2          # s5 = (effectiveBits + 3) / 4

reverse_loop:
    beqz s5, reverse_done   # If iteration count is zero, exit the loop

    slli s2, s2, 4          # result <<= 4
    andi s4, a0, 0xF        # s4 = n & 0xF

    # Get the reversed 4 bits from the lookup table
    la t0, reverse_table
    add t0, t0, s4
    lb s4, 0(t0)            # s4 = reverse_table[n & 0xF]

    or s2, s2, s4           # result |= reversed bits

    srli a0, a0, 4          # n >>= 4
    addi s5, s5, -1         # Decrement iteration count

    j reverse_loop

reverse_done:
    # Left shift result by leadingZeros bits
    mv a0, s2

    beqz s1, reverse_end
    sll a0, a0, s1          # result <<= leadingZeros

reverse_end:
    # Restore registers
    lw ra, 24(sp)
    lw s0, 20(sp)
    lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
    lw s4, 4(sp)
    lw s5, 0(sp)
    addi sp, sp, 28
    ret

# Function to count leading zeros (CLZ)
my_clz:
    # Prologue: Save registers
    addi sp, sp, -24        # Reserve stack space
    sw ra, 20(sp)           # Save return address
    sw s0, 16(sp)           # Save s0 (index)
    sw s1, 12(sp)           # Save s1 (count)
    sw s2, 8(sp)            # Save s2 (temporary)
    sw s3, 4(sp)            # Save s3 (temporary)
    sw s4, 0(sp)            # Save s4 (temporary)

    li s0, 31               # Initialize s0 = 31 (bit index)
    li s1, 0                # Initialize s1 = 0 (leading zeros count)

clz_loop:
    li s4, 0x1              # Load 1 into s4
    sll s2, s4, s0          # s2 = 1 << s0
    and s3, a0, s2          # s3 = a0 & s2 (test bit at position s0)
    bne s3, x0, clz_done    # If bit is 1, break loop

    addi s1, s1, 1          # Increment leading zeros count
    addi s0, s0, -1         # Decrement bit index

    bge s0, x0, clz_loop    # If s0 >= 0, continue loop

clz_done:
    mv a0, s1               # Move leading zeros count to a0
    # Epilogue: Restore registers
    lw ra, 20(sp)           # Restore return address
    lw s0, 16(sp)           # Restore s0 (index)
    lw s1, 12(sp)           # Restore s1 (count)
    lw s2, 8(sp)            # Restore s2 (temporary)
    lw s3, 4(sp)            # Restore s3 (temporary)
    lw s4, 0(sp)            # Restore s4 (temporary)
    addi sp, sp, 24         # Restore stack space
    ret                     # Return from function
