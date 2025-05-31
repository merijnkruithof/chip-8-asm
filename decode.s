// Constants for opcode decoding
.equ OP_NNN_MASK, 0x0FFF
.equ OP_NN_MASK,  0x00FF
.equ OP_N_MASK,   0x000F
.equ OP_X_MASK,   0x0F00
.equ OP_Y_MASK,   0x00F0
.equ OP_MASK,     0xF000

.section .text
.global decode_instruction

decode_instruction:
    stp x29, x30, [sp, #-16]!

    // Store the opcode, x, y, nnn, nn, and n values into registers, so we can handle it
    // accordingly. Every value except nnn, which is a half word, is just a byte, but we'll store everything
    // as a halfword:
    // w0 - contains the instruction.
    // w1 - contains nnn
    // w2 - contains nn
    // w3 - contains n
    // w4 - contains x
    // w5 - contains y
    // w6 - contains the opcode.
    and w1, w0, OP_NNN_MASK // nnn
    and w2, w0, OP_NN_MASK // nn
    and w3, w0, OP_N_MASK // n
    and w4, w0, OP_X_MASK // x
    lsr w4, w4, #8 // x
    and w5, w0, OP_Y_MASK // y
    lsr w5, w5, #4 // y
    and w6, w0, OP_MASK // opcode
    lsr w6, w6, #12 // opcode

    ldp x29, x30, [sp], #16
    ret