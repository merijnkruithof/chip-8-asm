.section .text
.global _start
.extern init_cpu
.extern fetch_instruction
.extern decode_instruction
.extern render
.extern handle_instruction
.extern initialize_graphics

_start:
    bl init_cpu
    bl initialize_graphics

    // Create the main loop.
    mov x0, #1 // 1 means that the main loop is active; 0 means that the program can be killed.
main_loop:
    // Fetch
    bl fetch_instruction
    cmp w0, #-1 // error
    beq exit

    // Decode
    //mov w0, w5 // decode_instruction uses w0 as starting argument, so we'll have to move w5 to w1.
    bl decode_instruction // decode the insturction in w0.

    // Handle instruction
    bl handle_instruction

    // Execute
    bl render

    b main_loop
exit:
    mov     x0, #0
    mov     x8, #93
    svc     #0

.section .data
.global ram
.global registers
.global index_register
.global pc
.global fontset
.global cstack // cstack stands for chip-8 stack.
.global csp // csp stands for chip-8 stack pointer.
.global framebuffer

cstack:
    .rept 16
    .hword 0
    .endr
csp:
    .balign 1
    .xword 0
ram:
    .balign 4096
    .skip 4096
registers:
    .balign 4
    .zero 16
index_register:
    .balign 2
    .zero 2
pc:
    .balign 2
    .zero 2
framebuffer:
    .balign 2048
    .zero 64 * 32
fontset:
    .byte 0xF0, 0x90, 0x90, 0x90, 0xF0 // 0
    .byte 0x20, 0x60, 0x20, 0x20, 0x70 // 1
    .byte 0xF0, 0x10, 0xF0, 0x80, 0xF0 // 2
    .byte 0xF0, 0x10, 0xF0, 0x10, 0xF0 // 3
    .byte 0x90, 0x90, 0xF0, 0x10, 0x10 // 4
    .byte 0xF0, 0x80, 0xF0, 0x10, 0xF0 // 5
    .byte 0xF0, 0x80, 0xF0, 0x90, 0xF0 // 6
    .byte 0xF0, 0x10, 0x20, 0x40, 0x40 // 7
    .byte 0xF0, 0x90, 0xF0, 0x90, 0xF0 // 8
    .byte 0xF0, 0x90, 0xF0, 0x90, 0x90 // A
    .byte 0xE0, 0x90, 0xE0, 0x90, 0xE0 // B
    .byte 0xF0, 0x80, 0x80, 0x80, 0xF0 // C
    .byte 0xE0, 0x90, 0x90, 0x90, 0xE0 // D
    .byte 0xF0, 0x80, 0xF0, 0x80, 0xF0 // E
    .byte 0xF0, 0x80, 0xF0, 0x80, 0x80 // F