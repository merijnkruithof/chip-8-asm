.section .text
.global handle_instruction

.extern PIXEL_OFF
.extern CUTOFF_POINT
.extern write_y_axis
.extern framebuffer
.extern ram
.extern index_register
.extern registers

// Method arguments:
// w0 - contains the instruction (hi 8 bits = opcode, rest = params)
// w1 - contains nnn
// w2 - contains nn
// w3 - contains n (height)
// w4 - contains x (Vx index)
// w5 - contains y (Vy index)
// w6 - contains the opcode.
handle_instruction:
    stp    x29, x30, [sp, #-16]!
    cmp    w6, #0x00
    beq    generic_zero_handler
    cmp    w6, #0x1
    beq    jmp_handler
    cmp    w6, #0x6
    beq    set_register_handler
    cmp    w6, #0x7
    beq    add_register_values
    cmp    w6, #0xA
    beq    set_index_register
    cmp    w6, #0xD
    beq    draw_handler
    b      exit

generic_zero_handler:
    cmp    w0, #0x00E0
    bne    exit
zero_graphics:
    adrp   x8, framebuffer
    add    x8, x8, :lo12:framebuffer
    mov    x9, #0              // counter
zero_graphics_loop:
    mov    w10, #0
    strb   w10, [x8]
    cmp    x9, #2048
    bge    exit
    add    x9, x9, #1
    add    x8, x8, #1
    b      zero_graphics_loop

jmp_handler:
    adrp   x8, pc
    add    x8, x8, :lo12:pc
    strb   w1, [x8]
    b      exit

set_register_handler:
    cmp    w4, #16
    bge    exit
    // load base van registers[]
    adrp   x8, registers
    add    x8, x8, :lo12:registers
    // offset = x4
    add    x8, x8, x4, LSL #0          // w4 wordt automatisch UXTW→x4 gebruikt
    // write registers[x] = nn (8-bit)
    strb   w2, [x8]
    b      exit

add_register_values:
    cmp    w4, #16
    bge    exit
    adrp   x8, registers
    add    x8, x8, :lo12:registers
    add    x8, x8, x4, LSL #0          // UXTW #0 impliciet
    ldrb   w9, [x8]
    add    w9, w9, w2
    strb   w9, [x8]
    b      exit

set_index_register:
    adrp   x8, index_register
    add    x8, x8, :lo12:index_register
    strh   w1, [x8]
    b      exit

draw_handler:
    adrp   x8, registers
    add    x8, x8, :lo12:registers
    ldrb   w9, [x8, w4, UXTW #0]      // w9 = registers[Vx]
    and    w10, w9, #0x3F             // w10 = Vx & 0x3F  (x0)

    ldrb   w9, [x8, w5, UXTW #0]      // w9 = registers[Vy]
    and    w11, w9, #0x1F             // w11 = Vy & 0x1F  (y0)

    mov    w12, #0
    strb   w12, [x8, #0xF]            // registers[0xF] = 0

    adrp   x9, index_register
    add    x9, x9, :lo12:index_register
    ldrh   w12, [x9]

    adrp   x13, ram
    add    x13, x13, :lo12:ram

    mov    w14, #0

draw_loop_row:
    cmp    w14, w3
    bge    draw_exit

    add    w15, w12, w14              // w15 = I + i
    ldrb   w16, [x13, w15, UXTW #0]   // w16 = memory[I+i]
    mov    w17, #0                    // w17 = j

draw_loop_col:
    cmp    w17, #8
    bge    draw_row_next

    mov    w18, #0x80
    lsr    w18, w18, w17
    tst    w16, w18
    beq    draw_skip_bit

    add    w19, w10, w17
    and    w19, w19, #0x3F

    add    w20, w11, w14
    and    w20, w20, #0x1F

    mov    w21, #64
    mul    w22, w20, w21
    add    w22, w22, w19

    adrp   x23, framebuffer
    add    x23, x23, :lo12:framebuffer
    uxtw   x22, w22
    add    x23, x23, x22
    ldrb   w24, [x23]

    cmp    w24, #1
    bne    draw_set_pixel

    mov    w25, #1
    strb   w25, [x8, #0xF]

    mov    w26, #0
    strb   w26, [x23]

    b      draw_skip_bit

draw_set_pixel:
    mov    w26, #1
    strb   w26, [x23]
draw_skip_bit:
    add    w17, w17, #1
    b      draw_loop_col
draw_row_next:
    add    w14, w14, #1
    b      draw_loop_row
draw_exit:
    b      exit
exit:
    ldp    x29, x30, [sp], #16
    ret