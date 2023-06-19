    .code16
    .text
    .global start

    .equ BOOTSEG, 0x07c0
    .equ SYSSEG, 0x1000
    .equ SYSLEN, 17
    .equ LOADER_SECTOR_LBA, 0x1

    ljmp $BOOTSEG, $start

start:
    mov %cs, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov %ax, %fs
    mov %ax, %gs
    mov $0xff00, %sp

clear_screen:
    mov $0x06, %ah
    mov $0, %al
    mov $0, %cx
    mov $0xffff, %dx
    mov $0x6f, %bh
    int $0x10

init_cursor_pos:
    mov $0x02, %ah
    mov $0, %dx
    mov $0, %bh
    int $0x10

begin_read_disk:
    mov $LOADER_SECTOR_LBA, %bx
    mov $SYSLEN, %cx
    mov $SYSSEG, %ax
    mov %ax, %ds

do_read_disk:
    # 设置读取的扇区数
    mov %cl, %al
    mov $0x1f2, %dx
    out %al, %dx
    
    # 设置lba地址
    # 设置低8位
    mov %bl, %al
    mov $0x1f3, %dx
    out %al, %dx

    # 设置中8位
    shr $8, %bx
    mov %bl, %al
    mov $0x1f4, %dx
    out %al, %dx
    
    # 设置高8位
    shr $8, %bx
    mov %bl, %al
    mov $0x1f5, %dx
    out %al, %dx
    
    # 设置高4位和device
    shr $8, %bx
    and $0x0f, %bl #lba第24-27位
    or $0xe0, %bl  #设置7-4位为1110，表示LBA模式
    mov %bl, %al
    mov $0x1f6, %dx
    out %al, %dx
        
    # 向0x1f7端口写入读命令0x20
    mov $0x20, %al
    mov $0x1f7, %dx
    out %al, %dx 

wait_ready:
    nop
    # 检测硬盘状态
    in %dx, %al
    and $0x88, %al #第4位为1表示硬盘准备好数据传输，第7位为1表示硬盘忙
    cmp $0x08, %al
    jnz wait_ready   #磁盘数据没准备好，继续循环检查
        
    #设置循环次数到cx
    mov %cx, %ax #乘法ax存放目标操作数
    mov $0x100, %dx
    mul %dx
    mov %ax, %cx   #循环次数 = 扇区数 x 512 / 2 
    mov $0, %bx
    mov $0x1f0, %dx
    
read_data:
    #从0x1f0端口读数据
    in %dx, %ax
    mov %ax, (%bx)
    add $2, %bx
    loop read_data

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
