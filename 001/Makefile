UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
	AS=as
	LD=ld
endif

ifeq ($(UNAME), Darwin)
	AS=i686-elf-as
	LD=i686-elf-ld
	BOCHS_FLAG='display_library: sdl2'
endif

QEMU=qemu-system-i386
BOCHS=bochs
BOOTIMG=boot.img

.PHONY=clean run all

all: $(BOOTIMG)

boot.img: bootsect.s
	@$(AS) -o bootsect.o bootsect.s
	@$(LD) --oformat binary -Ttext 0x7c00 -o bootsect bootsect.o
	@dd if=bootsect of=$(BOOTIMG) bs=512 count=1
	@echo "Success build $(BOOTIMG)."

run: $(BOOTIMG)
	$(QEMU) -boot a -fda $(BOOTIMG)

run_bochs: $(BOOTIMG)
	$(BOCHS) -q $(BOCHS_FLAG)

run_debug: $(BOOTIMG)
	$(QEMU) -s -S -boot a -fda $(BOOTIMG)

clean:
	@rm -f bootsect bootsect.o $(BOOTIMG)
