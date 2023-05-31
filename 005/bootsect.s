    .code32
    .global start

    .equ MULTIBOOT_HEADER_MAGIC, 0x1BADB002
    .equ MULTIBOOT_HEADER_FLAGS, 0
    .equ MULTIBOOT_HEADER_CHECKSUM, -0x1BADB002

    .long MULTIBOOT_HEADER_MAGIC
    .long MULTIBOOT_HEADER_FLAGS
    .long MULTIBOOT_HEADER_CHECKSUM

start:
    // 黑底红字
    movb $0x04, %ah 

    movb $'H', %al
    movl $0xb8000, %edi
    movw %ax, (%edi)

    movb $'e', %al
    addl $2, %edi
    movw %ax, (%edi)

    movb $'l', %al
    addl $2, %edi
    movw %ax, (%edi)

    movb $'l', %al
    addl $2, %edi
    movw %ax, (%edi)

    movb $'o', %al
    addl $2, %edi
    movw %ax, (%edi)

    cli
    hlt
