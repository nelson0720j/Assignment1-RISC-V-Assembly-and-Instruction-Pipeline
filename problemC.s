main:
    # Call test function
    jal ra, test            # Call test function, result will be in a0

    # Display result
    li a7, 1                # Prepare for ecall (print integer)
    ecall                   # Print the result (true/false) in a0
    
    li a7, 10               # Exit program
    ecall

# Test function to compare actual and expected result
test:
    addi sp, sp, -16        # Reserve stack space
    sw ra, 12(sp)           # Save return address
    sw t0, 8(sp)            # Save temp register

    # Test case: fp16_to_fp32
    li a0, 0x3C00           # Load test value
    jal ra, fp16_to_fp32    # Call fp16_to_fp32
    li t0, 0x3F800000       # Expected result (for fp16=0x6219)
    bne a0, t0, fail        # If result not equal to expected, jump to fail

    # Test case: my_clz
    li a0, 0x00001000       # Load test value
    jal ra, my_clz          # Call my_clz
    li t0, 19               # Expected result (for clz(0x00001000))
    bne a0, t0, fail        # If result not equal to expected, jump to fail

    # Test case: fabsf
    li a0, 0x80000000
    jal ra, fabsf
    li t0, 0x00000000
    bne a0, t0, fail
    
    # If both tests pass
    li a0, 1                # Return true (1)
    j end_test

fail:
    li a0, 0                # Return false (0)

end_test:
    lw ra, 12(sp)           # Restore return address
    lw t0, 8(sp)            # Restore temp register
    addi sp, sp, 16         # Restore stack space
    ret

fabsf:
    addi sp, sp, -8
    sw ra, 4(sp)
	sw s0, 0(sp)
        
    li s0, 0x7FFFFFFF   
    and a0, a0, s0    
    
    lw s0, 0(sp)          
    lw ra, 4(sp)     
    addi sp, sp, 8   
    ret            

fp16_to_fp32:
    addi sp, sp, -32     
    sw ra, 28(sp)         
    sw s0, 24(sp)         
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)          
    sw s5, 4(sp)
    sw s6, 0(sp)         

    mv s0, a0           # s0 store input uint16      
    slli s1, s0, 16     # s1 store w   
    li t0, 0x80000000       
    and s2, s1, t0      # s2 store sign
    li t0, 0x7FFFFFFF       
    and s3, s1, t0      # s3 store nonsign    

    mv a0, s3           #    
    jal ra, my_clz       
    mv s4, a0           # s4 store my_clz result(renorm_shift)   

    li s5, 6            # s5 store int 6
    blt s4, s5, set_zero     
    addi s4, s4, -5
    j continue      
set_zero:
    li s4, 0 
     
continue:
    li t1, 0x04000000        
    add s5, s3, t1           
    srli s5, s5, 8           
    li t1, 0x7F800000       
    and s5, s5, t1     # s5 update store inf_nan_mask       
    
    addi s6, s3, -1         
    srli s6, s6, 31    # s6 store zero_mask
    
    sll s3, s3, s4     # nonsign << renorm_shift
    srli s3, s3, 3     # s3 store (nonsign << renorm_shift >> 3)
    
    li t1, 0x70
    sub t1, t1, s4     # (0x70 - renorm_shift)
    slli t1, t1, 23    # t1 store ((0x70 - renorm_shift) << 23)
    
    add s3, s3, t1
    or s3, s3, s5
    
    not t1, s6
    and s3, s3, t1
    
    or s3, s3, s2
    mv a0, s3
    
    lw ra, 28(sp)         
    lw s0, 24(sp)         
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)          
    lw s5, 4(sp)
    lw s6, 0(sp)         
    addi sp, sp, 32
    ret
    
    
                      


# Function to count leading zeros (CLZ)
my_clz:
    addi sp, sp, -24
    sw ra, 20(sp)    
    sw s0, 16(sp)     
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)      

    li s0, 31         # s0 = i
    li s1, 0          # s1 = count

loop:
    li s4, 0x1        
    sll s2, s4, s0      
    and s3, a0, s2    
    bne s3, x0, done    

    addi s1, s1, 1   
    addi s0, s0, -1   

    bge s0, x0, loop

done:
    mv a0, s1            
    lw ra, 20(sp)    
    lw s0, 16(sp)     
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)      
    addi sp, sp, 24  
    ret