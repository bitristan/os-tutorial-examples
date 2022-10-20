        .code16
        .global _start

_start:
	mov	%cs, %ax
	mov	%ax, %ds
	mov	%ax, %es
	call	_print
_loop:
	jmp     _loop
_print:
        mov     $0x03, %ah
        mov     $0, %bh
        int     $0x10  # 读取当前光标位置，调用完成光标位置保存在dh和dl寄存器中

	mov	$msg, %bp
	mov	$12, %cx
	mov	$0x01301, %ax
	mov	$0x000c, %bx
	int	$0x10  # 输出字符串
	ret

msg:
        .asciz "Hello world!"

        . = 510
        .word 0xaa55
