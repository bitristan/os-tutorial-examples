# os-tutorial

- 001 simple boot loader print hello world.

注意：系统启动的时候跳转到0x7c00内存处执行，此时cs寄存器为0x0，ip寄存器为0x7c00，所以链接的时候要加-Ttext 0x7c00选项，将text段偏移设置为0x7c00。当然也可以使用-Ttext 0将text端偏移设置为0，但是这个时候需要在代码中加一条跳转指令，将cs寄存器设置为0x7c00，ip寄存器设置为0x0。ljmp $0x07c0,$_start.
