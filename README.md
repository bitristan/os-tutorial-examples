# os-tutorial

## 001 simple boot loader print hello world

- 系统启动的时候跳转到0x7c00内存处执行，此时cs寄存器为0x0，ip寄存器为0x7c00，所以链接的时候要加-Ttext 0x7c00选项，将text段偏移设置为0x7c00
- 也可以使用-Ttext 0将text端偏移设置为0，但是这个时候需要在代码中加一条跳转指令，将cs寄存器设置为0x7c00，ip寄存器设置为0x0: ljmp $0x07c0,$_start

## 002 enter to protect mode

- 640K-1M为保留区域，其中显存0xB8000~0xBFFFF，BIOS 0xF0000~0xFFFFF
- 我们将head.s加载到0x10000地址处运行，代码段和数据段的段基址为0x10000，推荐将代码移动到内存0开始处，段基址设置为0，这样代码写起来比较容易，目前我们没有这么做
- 0xb8000为显存起始地址，由于代码基地址为0x10000，所以对应屏幕第12行的相对地址为0xa8b40
- 1.44M软件一个磁道对应18个扇区，所以SYSLEN定义为17，只读一个磁道

## 003 run multiple process

- 系统引导后从0x7c00处开始执行
- 首先读取引导扇区后面的代码到内存0x10000处，然后将代码移动到0x0处
- 设置idt和gdt，进入保护模式
- 在保护模式下，重新设置idt和gdt，设置时钟中断
- 构造堆栈，使用iret指令执行任务0
- 在时钟中断中切换任务0和任务1


## FAQ

### linux下无法执行run_bochs

在linux下需要将bochsrc配置文件中的display_library一行注释掉，mac系统下运行需要设置display_library
