    .code16
    .text
    .global start

    .equ BOOTSEG, 0x07c0
    .equ SYSSEG, 0x1000
    .equ SYSLEN, 17

    ljmp $BOOTSEG, $start

start:
    mov %cs, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0xff00, %sp

load_system:
    mov $SYSSEG, %ax
    mov %ax, %es
    mov $0x0200+SYSLEN, %ax
    xor %bx, %bx
    xor %dx, %dx
    mov $0x0002, %cx
    int $0x13
    jnc ok_load
    mov $0x0000, %dx
    mov $0x0000, %ax
    // reset disk and read again
    int $0x13
    jmp load_system

ok_load:
    cli

    mov $BOOTSEG, %ax
    mov %ax, %ds
    lidt idt_48
    lgdt gdt_48

    mov $0x1, %ax
    lmsw %ax

    ljmp $0x8, $0

gdt:
    .word 0,0,0,0    # 空描述符

    .word 0x07FF     # 8Mb - limit=2047 (2048*4096=8Mb)
    .word 0x0000     # base address=0x10000
    .word 0x9A01     # code read/exec
    .word 0x00C0     # granularity=4096, 386
                     #
    .word 0x07FF     # 8Mb - limit=2047 (2048*4096=8Mb)
    .word 0x0000     # base address=0x10000
    .word 0x9201     # data read/write
    .word 0x00C0     # granularity=4096, 386

idt_48:
    .word 0, 0, 0

gdt_48:
    .word 0x7ff             # gdt limit=2048, 256 GDT entries
    .word 0x7c00+gdt, 0     # gdt base = 07xxx

    . = 510

boot_flag:
    .word 0xaa55
