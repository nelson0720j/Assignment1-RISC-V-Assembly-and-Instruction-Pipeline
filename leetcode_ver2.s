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
    # Prologue: Save registers
    addi sp, sp, -24        # Reserve stack space
    sw ra, 20(sp)           # Save return address
    sw s0, 16(sp)           # Save s0 (n)
    sw s1, 12(sp)           # Save s1 (leadingZeros)
    sw s2, 8(sp)            # Save s2 (result)
    sw s3, 4(sp)            # Save s3 (effectiveBits)
    sw s4, 0(sp)            # Save s4 (temporary)

    mv s0, a0               # Save n in s0

    # Call my_clz to get leading zeros
    jal ra, my_clz          # Input is a0 (n), output is a0 (leadingZeros)

    mv s1, a0               # Store leadingZeros in s1

    li s2, 32
    sub s3, s2, s1          # s3 = effectiveBits = 32 - leadingZeros

    li s2, 0                # Initialize result = 0

    mv a0, s0               # Restore n in a0

    beqz s3, reverse_done   # If effectiveBits == 0, skip loop

reverse_loop:
    slli s2, s2, 1          # result <<= 1
    andi s4, a0, 1          # s4 = n & 1
    or s2, s2, s4           # result |= (n & 1)
    srli a0, a0, 1          # n >>= 1
    addi s3, s3, -1         # Decrement effectiveBits

    bnez s3, reverse_loop   # If effectiveBits != 0, continue loop

reverse_done:
    # Shift result left by leadingZeros
    mv a0, s2               # Move result to a0

    beqz s1, reverse_end    # If leadingZeros == 0, skip shift

    sll a0, a0, s1          # result <<= leadingZeros

reverse_end:
    # Epilogue: Restore registers
    lw ra, 20(sp)           # Restore return address
    lw s0, 16(sp)           # Restore s0 (n)
    lw s1, 12(sp)           # Restore s1 (leadingZeros)
    lw s2, 8(sp)            # Restore s2 (result)
    lw s3, 4(sp)            # Restore s3 (effectiveBits)
    lw s4, 0(sp)            # Restore s4 (temporary)
    addi sp, sp, 24         # Restore stack space
    ret                     # Return from function

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
