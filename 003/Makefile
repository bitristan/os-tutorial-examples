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

boot.img: bootsect system
	@dd if=bootsect of=$(BOOTIMG) bs=512 count=1
	@dd if=system of=$(BOOTIMG) bs=512 seek=1
	@echo "Success build $(BOOTIMG)."

bootsect: bootsect.s
	@$(AS) -o bootsect.o bootsect.s
	@$(LD) --oformat binary -Ttext 0 -e start -o bootsect bootsect.o

system: head.s
	@$(AS) -o head.o head.s
	@$(LD) --oformat binary -Ttext 0 -e start -o system head.o

run: $(BOOTIMG)
	$(QEMU) -boot a -fda $(BOOTIMG)

run_bochs: $(BOOTIMG)
	$(BOCHS) -q $(BOCHS_FLAG)

run_debug: $(BOOTIMG)
	$(QEMU) -s -S -boot a -fda $(BOOTIMG)

clean:
	@rm -f bootsect system *.o $(BOOTIMG)
