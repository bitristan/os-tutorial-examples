#define SECTSIZE  512

typedef unsigned int uint;
typedef unsigned short ushort;
typedef unsigned char uchar;

void showHello();
void waitdisk(void);
void readsect(void *dst, uint offset);
void outb(ushort port, uchar data);
void insl(int port, void *addr, int cnt);
uchar inb(ushort port);

void bootmain(void)
{
    unsigned char *p = (unsigned char *) 0x10000;
    // 读取第1个硬盘，即boot.img的第2个扇区（扇区编号从0开始）到内存地址0x10000处
    readsect((void*)p, 1);

    showHello();

    while(1) {}
}

void showHello()
{
    char *p = (char *)0xb8000;
    p[0] = 'H';
    p[1] = 0x2f;
}

void waitdisk(void)
{
    // Wait for disk ready.
    while((inb(0x1F7) & 0xC0) != 0x40);
}

// Read a single sector at offset into dst.
void readsect(void *dst, uint offset)
{
    // Issue command.
    waitdisk();
    outb(0x1F2, 1);   // count = 1
    outb(0x1F3, offset);
    outb(0x1F4, offset >> 8);
    outb(0x1F5, offset >> 16);
    outb(0x1F6, (offset >> 24) | 0xE0);
    outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

    // Read data.
    waitdisk();
    insl(0x1F0, dst, SECTSIZE/4);
}

inline uchar inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
  return data;
}


inline void outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

inline void insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
