UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	AS=as --32
	LD=ld -m elf_i386
endif

ifeq ($(UNAME), Darwin)
	AS=i686-elf-as
	LD=i686-elf-ld
endif

QEMU=qemu-system-i386
BOOTIMG=kernel.iso
ISODIR=isodir
KERNEL_DIR=$(ISODIR)/boot/kernel

.PHONY=clean run all

all: $(BOOTIMG)

kernel.iso: bootsect
	@cp bootsect $(KERNEL_DIR)
	@grub-mkrescue -o $(BOOTIMG) $(ISODIR)
	@echo "Success build $(BOOTIMG)."

bootsect: bootsect.s
	@$(AS) -o bootsect.o bootsect.s
	@$(LD) -Ttext 0x100000 -e start -o bootsect bootsect.o

run: $(BOOTIMG)
	$(QEMU) -cdrom $(BOOTIMG)

run_debug: $(BOOTIMG)
	$(QEMU) -s -S -cdrom $(BOOTIMG)

clean:
	@rm -f bootsect *.o $(BOOTIMG) $(KERNEL_DIR)
