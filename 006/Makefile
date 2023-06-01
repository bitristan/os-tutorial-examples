UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	AS=as --32
	LD=ld -m elf_i386
	CC=gcc
	CFLAGS=-g -m32 -fno-builtin -fno-pic
endif

ifeq ($(UNAME), Darwin)
	AS=i686-elf-as
	LD=i686-elf-ld
	CC=i686-elf-gcc
	CFLAGS=-g -fno-builtin
endif

GDB=gdb
QEMU=qemu-system-i386
BOOTIMG=kernel.elf

.PHONY=clean run all

all: $(BOOTIMG)

$(BOOTIMG): bootsect.s kernel.c
	@$(AS) -o bootsect.o bootsect.s
	@$(CC) $(CFLAGS) -c kernel.c -o kernel.o
	@$(LD) -Ttext 0x100000 -e start -o $(BOOTIMG) bootsect.o kernel.o
	@echo "Success build $(BOOTIMG)."

run: $(BOOTIMG)
	$(QEMU) -kernel $(BOOTIMG)

run_debug: $(BOOTIMG)
	$(QEMU) -s -S -kernel $(BOOTIMG) &
	${GDB} -q -ex "target remote localhost:1234" -ex "symbol-file $(BOOTIMG)"

clean:
	@rm -f bootsect *.o $(BOOTIMG)
