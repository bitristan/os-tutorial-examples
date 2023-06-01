    .code32
    .global start

    .equ MULTIBOOT_HEADER_MAGIC, 0x1BADB002
    .equ MULTIBOOT_HEADER_FLAGS, 0
    .equ MULTIBOOT_HEADER_CHECKSUM, -0x1BADB002

    .long MULTIBOOT_HEADER_MAGIC
    .long MULTIBOOT_HEADER_FLAGS
    .long MULTIBOOT_HEADER_CHECKSUM

start:
    movl $stack_top, %esp

    pushl %eax
    call kernel_main

    hlt

    .section .bss
    .align 16
    .skip 0x4000
stack_top:
