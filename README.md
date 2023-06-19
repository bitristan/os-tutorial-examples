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

## 003-extra bochs debug

在003工程中，使用qemu能运行成功，但是使用bochs运行的话，无法出现两个进程在屏幕交替输出。多半是程序有什么bug，我们来看一下如何调试解决这个问题。

在bochs运行的时候往上看bochs的输出日志，可以发现如下信息
```
00014795176e[CPU0  ] write_virtual_checks(): no write access to seg
00014795176e[CPU0  ] interrupt(): vector must be within IDT table limits, IDT.limit = 0x0
00014795176e[CPU0  ] interrupt(): vector must be within IDT table limits, IDT.limit = 0x0
00014795176i[CPU0  ] CPU is in protected mode (active)
00014795176i[CPU0  ] CS.mode = 32 bit
00014795176i[CPU0  ] SS.mode = 32 bit
00014795176i[CPU0  ] EFER   = 0x00000000
00014795176i[CPU0  ] | EAX=00080118  EBX=00000000  ECX=00000100  EDX=00008e00
00014795176i[CPU0  ] | ESP=00000bd4  EBP=00000000  ESI=000e2000  EDI=00000198
00014795176i[CPU0  ] | IOPL=0 id vip vif ac vm RF nt of df if tf sf ZF af PF cf
00014795176i[CPU0  ] | SEG sltr(index|ti|rpl)     base    limit G D
00014795176i[CPU0  ] |  CS:0008( 0001| 0|  0) 00000000 007fffff 1 1
00014795176i[CPU0  ] |  DS:0008( 0001| 0|  0) 00000000 007fffff 1 1
00014795176i[CPU0  ] |  SS:0010( 0002| 0|  0) 00000000 007fffff 1 1
00014795176i[CPU0  ] |  ES:0000( 0005| 0|  0) 00000000 0000ffff 0 0
00014795176i[CPU0  ] |  FS:0000( 0005| 0|  0) 00000000 0000ffff 0 0
00014795176i[CPU0  ] |  GS:0000( 0005| 0|  0) 00000000 0000ffff 0 0
00014795176i[CPU0  ] | EIP=000000d2 (000000d2)
00014795176i[CPU0  ] | CR0=0x60000011 CR2=0x00000000
00014795176i[CPU0  ] | CR3=0x00000000 CR4=0x00000000
(0).[14795176] [0x0000000000d2] 0008:000000d2 (unk. ctxt): mov dword ptr ds:[edi], eax ; 8907
00014795176e[CPU0  ] exception(): 3rd (13) exception with no resolution, shutdown status is 00h, resetting
00014795176i[SYS   ] bx_pc_system_c::Reset(HARDWARE) called
00014795176i[CPU0  ] cpu hardware reset
00014795176i[APIC0 ] allocate APIC id=0 (MMIO enabled) to 0x0000fee00000
```

如果觉得命令行查看日志不方便的话，可以在bochsrc配置文件中加入如下一行，这样log就会输出到指定的文件中
```
log: output.log
```

下面我们根据错误日志来分析bug：

在错误日志中，我们先看EIP，看是哪条指令出错了，发现 EIP=000000d2

怎么查看0xd2处是哪条指令呢？

1. 由于进入head.s之后，我们的代码是从0x00处开始执行，所以可以重新进入bochs，使用 `b 0x00` 设置断点在物理地址0x00处，然后使用 `c` 指令执行到断点处
2. 然后使用 `u /100` 反汇编当前地址往下的100条指令，很容易看到 0xd2 处的指令
```
000000c0: (                    ): mov ax, dx                ; 6689d0
000000c3: (                    ): mov dx, 0x8e00            ; 66ba008e
000000c7: (                    ): lea edi, ds:0x00000198    ; 8d3d98010000
000000cd: (                    ): mov ecx, 0x00000100       ; b900010000
000000d2: (                    ): mov dword ptr ds:[edi], eax ; 8907
000000d4: (                    ): mov dword ptr ds:[edi+4], edx ; 895704

```
3. 根据指令操作的寄存器和操作数的值应该很容易可以对应到源文件head.s中的代码，是第80行的movl操作出错
```
    movl %eax, (%edi)
```
4. 使用 `b 0xd2` 设置断点在出错的这行指令处 (其实也可以省略步骤2和3，直接设置断点在 `0xd2` 处，然后使用 `u` 查看当前出错的指令)
5. 查看当前各种寄存器的值，分析为什么这条movl指令会出错，很容易看出，因为ds寄存器为0x08，是代码段选择符，因为代码段不可写，所以执行movl会报错，很明显ds寄存器应该设置为数据段选择符，由于我们的笔误写错了
6. 修复ds寄存器的赋值问题就行了，具体改动见本次commit，再次run_bochs运行成功。(为什么qemu能成功运行，这个很奇怪!)

## 004 multiboot

使用multiboot规范加载操作系统内核映像

1. 操作系统内核文件需要为elf格式
2. 操作系统被加载到0x100000处执行，所以编译的时候需要使用 -Ttext=0x100000 设置代码段偏移
3. qemu支持multiboot启动，使用 -kernel 参数指定内核文件
4. multiboot启动跳转到entry处执行时
   - 内核默认开启保护模式
   - eax寄存器的值为0x2BADB002，表明操作系统已经被兼容Multiboot规范的bootloader加载成功
   - ebx寄存器包含Multiboot信息数据结构的物理地址，通过它，启动载入器向操作系统传递重要信息
   - 代码段偏移为0，段限长为0xFFFFFFFF，数据段偏移为0，段限长为0xFFFFFFFF
   - 不开启分页模式
   - 关闭中断

具体详细规范见multiboot官方文档 [Multiboot Specification version 0.6.96](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html)

## 005 multiboot with grub

使用grub制作iso内核镜像

## 006 multiboot with c integrate

集成c语言环境。

- 由于c语言依赖栈，所以我们需要首先设置esp寄存器。在bootsect.s中，我们在bss段中定义了一个16KB大小的空间，stack_top指向此空间的高地址，将stack_top设置为栈顶即可。

## 007 boot from hard disk

从硬盘启动，从硬盘读取loader并执行

## 008 read ide hard disk in LBA mode

LBA模式读取ide硬盘

0x1f2: 读取扇区数
0x1f3: LBA低8位
0x1f4: LBA中8位
0x1f5: LBA高8位
0x1f6: 0-3位为LBA的24-27位，第4位为0表示主盘，第5位为1表示LBA模式，0表示CHS模式，第6位为1，第7位为1

本例中，读取boot.img的第1个扇区（从0开始）到内存便宜0x8000处，由于数据段从0x10000开始，所以最终数据会读到0x18000处，具体可以使用bochs调试查看。


## FAQ

### bochs运行

在mac下运行bochs需要添加参数: 'display_library: sdl2'
