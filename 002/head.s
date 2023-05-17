    .code32
    .text
    .global start

start:
    movl $0x10, %eax
    mov %ax, %ds

    mov $36, %ecx
    mov $msg, %edx
    movb $0x0c, %ah
    // 0xb8000 + 0x12*80*2
    mov $0xa8b40, %ebx

print:
    movb (%edx), %al
    movw %ax, (%ebx)
    dec %ecx
    jz loop
    add $2, %ebx
    add $1, %edx
    jmp print

loop:
    jmp loop

msg:
    .ascii "Welcome to protected mode!"
