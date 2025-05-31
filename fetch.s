.section .text
.global fetch_instruction

.equ MEMORY_END, 0xFFF

// fetch_instruction looks for the next instruction in memory and returns it.
//
// returns:
// w5 - the next instruction.
fetch_instruction:
    stp x29, x30, [sp, #-16]!

    adrp x0, pc // program counter address
    add x0, x0, :lo12:pc // add low bits of program counter address
    ldrh w1, [x0] // dereference program counter address

    // safety check. should never happen in real programs.
    cmp w1, #MEMORY_END
    bhs exit_with_error

    adrp x2, ram // load ram address
    add x2, x2, :lo12:ram // load lower bits of ram address
    add x2, x2, x1 // add program counter offset to ram address.

    ldrb w3, [x2] // load high byte
    ldrb w4, [x2, #1] // load low byte
    lsl w3, w3, #8 // logical shift left for high byte
    orr w5, w3, w4 // bitwise OR - high << 8 | low
    add w1, w1, #2 // increment pc by 2 (half word).
    strh w1, [x0] // store new program counter to pc.
    mov  w0, w5
exit:
    ldp x29, x30, [sp], #16
    ret
exit_with_error:
    mov w0, #-1
    ldp x29, x30, [sp], #16
    ret
