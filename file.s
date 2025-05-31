.section .text
.global file_read

file_read:
    stp x29, x30, [sp, #-16]!
    mov x20, x0

    // openat(AT_FDCWD, "rom.c8", O_RDONLY, 0)
    mov  x0, -100           // AT_FDCWD (current dir)
    adrp x1, rom_name
    add x1, x1, :lo12:rom_name
    mov x2, #0 // O_RDONLY
    mov x3, #0
    // x8 for syscall number
    mov x8, #56
    svc #0

    mov x19, x0

    // read(int fd, void *buf, size_t count)
    mov x0, x19
    mov x1, x20 // sliced memory buffer
    mov x2, #(4096 - 0x50)
    mov x8, #63
    svc #0

    ldp x29, x30, [sp], #16
    mov x0, x20
    ret

.section .data
rom_name:
    .ascii "project.ch8\0"
