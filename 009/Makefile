UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	AS=as
	LD=ld
endif

ifeq ($(UNAME), Darwin)
	AS=i686-elf-as
	LD=i686-elf-ld
endif

QEMU=qemu-system-i386
BOCHS=bochs
BOOTIMG=boot.img
GDB=gdb

.PHONY=clean run all

all: $(BOOTIMG)

boot.img: bootasm.S bootmain.c
	gcc -fno-pic -static -fno-builtin -fno-strict-aliasing -O2 -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer -fno-stack-protector -fno-pie -no-pie -fno-pic -nostdinc -I. -c bootasm.S
	gcc -fno-pic -static -fno-builtin -fno-strict-aliasing -O2 -Wall -MD -ggdb -m32 -Werror -fno-omit-frame-pointer -fno-stack-protector -fno-pie -no-pie -fno-pic -O -nostdinc -I. -c bootmain.c
	ld -m elf_i386 -N -e start -Ttext 0x7C00 -o bootblock.o bootasm.o bootmain.o
	objcopy -S -O binary -j .text bootblock.o bootblock
	./sign.pl bootblock
	dd if=/dev/zero of=$@ count=1000 bs=1024
	dd if=bootblock of=$@ count=1 bs=512 conv=notrunc
	dd if=bootblock.o of=$@ seek=1 conv=notrunc # 随便写入一些数据用于硬盘读取测试
	@echo "Success build $(BOOTIMG)."

run: $(BOOTIMG)
	$(QEMU) -drive file=$(BOOTIMG),index=0,media=disk,format=raw

run_debug: $(BOOTIMG)
	$(QEMU) -s -S -drive file=$(BOOTIMG),index=0,media=disk,format=raw &
	$(GDB) -q -x gdb.gdb -ex "symbol-file bootblock.o"

run_bochs: $(BOOTIMG)
	$(BOCHS) -q $(BOCHS_FLAG)

clean:
	@rm -f bootblock *.o *.d $(BOOTIMG)
