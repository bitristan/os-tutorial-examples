    .code32
    .text
    .global start

start:
    movl $0x10, %eax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov %ax, %fs
    mov %ax, %gs

    call check_ready

    mov $1, %ebx
    mov $1, %ecx
    call read_sector

    mov $36, %ecx
    mov $msg, %edx
    movb $0x6f, %ah
    mov $0xa8000, %ebx

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

read_sector:
    # Set the number of sectors to read
    mov %cl, %al
    mov $0x1f2, %dx
    out %al, %dx
    
    # Set the LBA address
    # low 8 bit
    mov %bl, %al
    mov $0x1f3, %dx
    out %al, %dx

    # middle 8 bit
    shr $8, %bx
    mov %bl, %al
    mov $0x1f4, %dx
    out %al, %dx
    
    # high 8 bit
    shr $8, %bx
    mov %bl, %al
    mov $0x1f5, %dx
    out %al, %dx
    
    # Set lba mode
    shr $8, %bx
    and $0x0f, %bl
    or $0xe0, %bl  #7-4 is 1110, means LBA mode
    mov %bl, %al
    mov $0x1f6, %dx
    out %al, %dx
        
    # Send the read command
    mov $0x20, %al
    mov $0x1f7, %dx
    out %al, %dx 

    # Wait for the disk to be ready
wait_ready:
    nop
    in %dx, %al
    and $0x88, %al
    cmp $0x08, %al
    jnz wait_ready
        
    # Read the data from the data port (0x1f7) into the memory location
    mov %cx, %ax
    mov $0x100, %dx
    mul %dx
    mov %ax, %cx
    mov $0x8000, %bx
    mov $0x1f0, %dx
    
read_data:
    in %dx, %ax
    mov %ax, (%bx)
    add $2, %bx
    loop read_data

    ret

check_ready: 
    mov $0x1f7, %dx
    in %dx, %al
    test $0x40, %al
    jz check_ready   
    ret   
