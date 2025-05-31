.section .text
.global init_cpu

.extern file_read

init_cpu:
    stp x29, x30, [sp, #-16]!

    // Load ROM into memory.
    adrp x0, ram
    add x0, x0, :lo12:ram
    add x0, x0, #0x200 // aoffset
    bl file_read

    // Set program counter to 0x200.
    adrp x0, pc
    add x0, x0, :lo12:pc
    mov w1, #0x200
    strh w1, [x0]

    // Stack initialization
    adrp x0, cstack
    add x0, x0, :lo12:cstack
    add x0, x0, #32

    // store the stack pointer
    adrp x1, csp
    add x1, x1, :lo12:csp
    str x0, [x1]

    // Store the fontset at offset 0x50.
    adrp x0, fontset // load fontset address
    add x0, x0, :lo12:fontset // load lower bits of fontset address

    adrp x1, ram // load ram
    add x1, x1, :lo12:ram
    add x1, x1, #0x50 // memory offset
    mov x2, #80 // font size in decimal.
loop_through_fontset:
    ldrb w3, [x0] // load byte currently in the fontset
    strb w3, [x1] // store byte in w3 to the address pointing at ram.
    add x0, x0, #1 // increment pointer to RAM.
    add x1, x1, #1 // increment pointer to fontset data.
    sub x2, x2, #1 // decrease font size.
    cmp x2, #0
    bhi loop_through_fontset
exit:
    ldp x29, x30, [sp], #16
    ret