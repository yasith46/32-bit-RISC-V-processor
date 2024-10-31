.global _boot
.text

_boot:
    /* Load the initial value from data memory (variable) */
    la      x6, variable       /* Load address of variable into x6 */
    lw      x7, 0(x6)          /* Load the value at the address (0xdeadbeef) into x7 */
    lw      x7, 0(x6)          /* Stall */

    /* Initialize some registers */
    addi    x1, x0, 1000       /* x1 = 1000 */
    addi    x2, x1, 2000       /* x2 = 3000 */
    addi    x5, x2, -1000      /* x5 = 2000 */
    
    /* Start of loop */
loop:
    sub     x3, x2, x5         /* x3 = x2 - x5 */
    
    /* Conditional branch: if x3 != 0, loop */
    bne     x3, x0, loop_body  /* If x3 != 0, jump to loop_body */
    
    /* Exit loop */
    j       end                /* Unconditional jump to end */

loop_body:
    addi    x5, x5, -1         /* Decrease x5 by 1 */
    j       loop               /* Unconditional jump to loop */

end:
    /* Write the value to data memory */
    li      x4, 0x12345678     /* Load immediate value to write */
    sw      x4, 0(x6)          /* Store the value to the memory location at x6 */
    
    /* End the program */
    nop                        /* No operation, end of program */

.data
variable:
    .word   0xdeadbeef          /* Variable initialized with 0xdeadbeef */
