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
	@rm -f $@
	@bximage -func=create -imgmode=flat -hd=10 -q $@
	@dd if=bootsect of=$@ bs=512 count=1 conv=notrunc
	@dd if=system of=$@ bs=512 seek=1 conv=notrunc
	@echo "Success build $(BOOTIMG)."

bootsect: bootsect.s
	$(AS) -o bootsect.o bootsect.s
	$(LD) --oformat binary -Ttext 0 -e start -o bootsect bootsect.o

system: head.s
	$(AS) -o head.o head.s
	$(LD) --oformat binary -Ttext 0 -e start -o system head.o

run: $(BOOTIMG)
	$(QEMU) -boot c -hda $(BOOTIMG)

run_bochs: $(BOOTIMG)
	$(BOCHS) -q $(BOCHS_FLAG)

run_debug: $(BOOTIMG)
	$(QEMU) -s -S -boot c -hda $(BOOTIMG)

clean:
	@rm -f bootsect system *.o $(BOOTIMG)
