.section .text
.global render
.global initialize_graphics
.global CUTOFF_POINT
.global write_y_axis
.global write_x_axis
.equ FRAMEBUFFER_WIDTH, 64
.equ FRAMEBUFFER_HEIGHT, 32
.equ CUTOFF_POINT, 2048

initialize_graphics:
    stp x29, x30, [sp, #-16]!
    adrp x0, framebuffer
    add x0, x0, :lo12:framebuffer
    mov x1, #0 // counter
initialize_graphics_loop:
    ldr x3, =pixel_off
    strb w3, [x0]
    add x1, x1, #1
    cmp x1, CUTOFF_POINT
    bge exit_initialize_graphics
    add x0, x0, #1
    b initialize_graphics_loop
exit_initialize_graphics:
    ldp x29, x30, [sp], #16
    ret

// x0 - offset
// x1 - value
write_x_axis:
    stp x29, x30, [sp, #-16]!
    adrp x2, framebuffer
    add x2, x2, :lo12:framebuffer
    cmp x0, #64
    bge exit_write_x_axis
    add x2, x2, x0
    strb w1, [x2]
exit_write_x_axis:
    ldp x29, x30, [sp], #16
    ret

// eg write_y_axis(0, 1) = second row, first item
// x0 - x
// x1 - y
// x2 - value
write_y_axis:
    stp x29, x30, [sp, #-16]!
    cmp x0, #FRAMEBUFFER_WIDTH
    bge exit_write_y_axis
    cmp x1, #FRAMEBUFFER_HEIGHT
    bge exit_write_y_axis
    mov x3, #64
    mul x1, x1, x3
    add x1, x1, x0
    adrp x4, framebuffer
    add x4, x4, :lo12:framebuffer
    add x4, x4, x1
    strb w2, [x4]
exit_write_y_axis:
    ldp x29, x30, [sp], #16
    ret
render:
    stp    x29, x30, [sp, #-16]!

    // clear screen
    mov    x0, #1
    ldr    x1, =clear_screen
    mov    x2, #7
    mov    x8, #64
    svc    #0
    mov    w19, #0
render_row_loop:
    cmp    w19, #FRAMEBUFFER_HEIGHT
    bge    render_done

    mov    w20, #0

render_col_loop:
    cmp    w20, #FRAMEBUFFER_WIDTH
    bge    render_end_of_row

    mov    w21, #64
    mul    w22, w19, w21
    add    w22, w22, w20

    adrp   x23, framebuffer
    add    x23, x23, :lo12:framebuffer
    uxtw   x22, w22
    add    x23, x23, x22
    ldrb   w24, [x23]

    cmp    w24, #1
    beq    render_print_on

    mov    x0, #1
    ldr    x1, =pixel_off
    mov    x2, #1
    mov    x8, #64
    svc    #0
    b      render_skip_to_next
render_print_on:
    mov    x0, #1
    ldr    x1, =pixel_on
    mov    x2, #3
    mov    x8, #64
    svc    #0
render_skip_to_next:
    add    w20, w20, #1
    b      render_col_loop
render_end_of_row:
    mov    x0, #1
    ldr    x1, =newline
    mov    x2, #1
    mov    x8, #64
    svc    #0

    add    w19, w19, #1
    b      render_row_loop
render_done:
    ldp    x29, x30, [sp], #16
    ret

.section .data
clear_screen:
    .asciz "\033[2J\033[H"
pixel_on:   .asciz "█"
pixel_off:  .asciz " "
newline:    .asciz "\n"