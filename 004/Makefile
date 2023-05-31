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
BOOTIMG=boot.img

.PHONY=clean run all

all: $(BOOTIMG)

boot.img: bootsect
	@cp bootsect $(BOOTIMG)
	@echo "Success build $(BOOTIMG)."

bootsect: bootsect.s
	@$(AS) -o bootsect.o bootsect.s
	@$(LD) -Ttext 0x100000 -e start -o bootsect bootsect.o

run: $(BOOTIMG)
	$(QEMU) -kernel $(BOOTIMG)

run_debug: $(BOOTIMG)
	$(QEMU) -s -S -kernel $(BOOTIMG)

clean:
	@rm -f bootsect *.o $(BOOTIMG)
