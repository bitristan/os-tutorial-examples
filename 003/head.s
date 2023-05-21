    .code32
    .text
    .global start

    .equ LATCH, 11930
    .equ SYSCODE_SEL, 0x08
    .equ SYSDATA_SEL, 0x10
    .equ SCREEN_SEL, 0x18
    .equ TSS0_SEL, 0x20
    .equ LDT0_SEL, 0x28
    .equ TSS1_SEL, 0x30
    .equ LDT1_SEL, 0x38

start:
    movl $SYSCODE_SEL, %eax
    mov %ax, %ds
    lss init_stack, %esp

    call setup_idt
    call setup_gdt

    movl $SYSCODE_SEL, %eax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    lss init_stack, %esp

    movb $0x36, %al
    movl $0x43, %edx
    outb %al, %dx
    movl $LATCH, %eax
    movl $0x40, %edx
    outb %al, %dx
    movb %ah, %al
    outb %al, %dx

    movl $0x00080000, %eax
    movw $timer_interrupt, %ax
    movw $0x8e00, %dx
    movl $SYSCODE_SEL, %ecx
    lea idt(, %ecx, 8), %esi
    movl %eax, (%esi)
    movl %edx, 4(%esi)
    movw $system_interrupt, %ax
    movw $0xef00, %dx
    movl $0x80, %ecx
    lea idt(, %ecx, 8), %esi
    movl %eax, (%esi)
    movl %edx, 4(%esi)

    pushfl
    andl $0xffffbfff, (%esp)
    popfl
    movl $TSS0_SEL, %eax
    ltr %ax
    movl $LDT0_SEL, %eax
    lldt %ax
    movl $0, current_task
    sti
    pushl $0x17
    pushl $init_stack
    pushfl
    pushl $0x0f
    pushl $task0
    iret

setup_gdt:
    lgdt gdt_48
    ret

setup_idt:
    lea ignore_int, %edx
    movl $0x00080000, %eax
    movw %dx, %ax
    movw $0x8e00, %dx
    lea idt, %edi
    mov $256, %ecx
rp_idt:
    movl %eax, (%edi)
    movl %edx, 4(%edi)
    addl $8, %edi
    dec %ecx
    jne rp_idt
    lidt idt_48
    ret

write_char:
    push %gs
    pushl %ebx
    mov $SCREEN_SEL, %ebx
    mov %bx, %gs
    movl screen_pos, %ebx
    shl $1, %ebx
    mov %ax, %gs:(%ebx)
    shr $1, %ebx
    incl %ebx
    cmpl $2000, %ebx
    jb 1f
    movl $0, %ebx
1:
    movl %ebx, screen_pos
    popl %ebx
    pop %gs
    ret

.align 4
ignore_int:
    push %ds
    pushl %eax
    movl $SYSDATA_SEL, %eax
    mov %ax, %ds
    movb $'C', %al
    movb $0x0c, %ah
    call write_char
    popl %eax
    pop %ds
    iret

.align 4
timer_interrupt:
    push %ds
    pushl %eax
    movl $SYSDATA_SEL, %eax
    mov %ax, %ds
    movb $0x20, %al
    outb %al, $0x20
    movl $1, %eax
    cmpl %eax, current_task
    je 1f
    movl %eax, current_task
    ljmp $TSS1_SEL, $0
    jmp 2f
1:
    movl $0, current_task
    ljmp $TSS0_SEL, $0
2:
    popl %eax
    pop %ds
    iret

.align 4
system_interrupt:
    push %ds
    pushl %edx
    pushl %ecx
    pushl %ebx
    pushl %eax
    movl $SYSDATA_SEL, %edx
    mov %dx, %ds
    call write_char
    popl %eax
    popl %ebx
    popl %ecx
    popl %edx
    pop %ds
    iret

.align 4
current_task: .long 0
screen_pos: .long 0

idt_48:
    .word 256*8-1
    .long idt

gdt_48:
    .word (end_gdt - gdt) - 1
    .long gdt

.align 4
idt:
    .fill 256, 8, 0

gdt:
    .quad 0x0000000000000000
    .quad 0x00c09a00000007ff   # 内核代码段描述符 0x08
    .quad 0x00c09200000007ff   # 内核数据段描述符 0x10
    .quad 0x00c0920b80000002   # 显存段描述符    0x18

    .word 0x68, tss0, 0xe900, 0x0  # TSS0段描述符 0x20
    .word 0x40, ldt0, 0xe200, 0x0  # LDT0段描述符 0x28
    .word 0x68, tss1, 0xe900, 0x0  # TSS1段描述符 0x30
    .word 0x40, ldt1, 0xe200, 0x0  # LDT1段描述符 0x38
end_gdt:
    .fill 128, 4, 0
init_stack:
    .long init_stack
    .word SYSDATA_SEL

.align 4
ldt0:
    .quad 0x0000000000000000
    .quad 0x00c0fa00000003ff
    .quad 0x00c0f200000003ff

tss0:
    .long 0
    .long krn_stk0, SYSDATA_SEL
    .long 0, 0, 0, 0, 0
    .long 0, 0, 0, 0, 0
    .long 0, 0, 0, 0, 0
    .long 0, 0, 0, 0, 0, 0
    .long LDT0_SEL, 0x8000000

    .fill 128, 4, 0
krn_stk0:

.align 4
ldt1:
    .quad 0x0000000000000000
    .quad 0x00c0fa00000003ff
    .quad 0x00c0f200000003ff

tss1:
    .long 0
    .long krn_stk1, SYSDATA_SEL
    .long 0, 0, 0, 0, 0
    .long task1, 0x200
    .long 0, 0, 0, 0
    .long usr_stk1, 0, 0, 0
    .long 0x17, 0x0f, 0x17, 0x17, 0x17, 0x17
    .long LDT1_SEL, 0x8000000

    .fill 128, 4, 0
krn_stk1:

task0:
    movl $0x17, %eax
    movw %ax, %ds
    mov $'A', %al
    mov $0x0c, %ah
    int $0x80
    movl $0xfff, %ecx
1:  loop 1b
    jmp task0

task1:
    mov $'B', %al
    mov $0x0e, %ah
    int $0x80
    movl $0xfff, %ecx
1:  loop 1b
    jmp task1

    .fill 128, 4, 0
usr_stk1:
