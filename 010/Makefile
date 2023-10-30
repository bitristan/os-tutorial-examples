.PHONY=clean run all

KERNEL=kernel.elf

all: $(KERNEL)

kernel.elf: boot.s kernel.c
	aarch64-linux-gnu-as boot.s -o boot.o
	aarch64-linux-gnu-gcc -ffreestanding -c kernel.c -o kernel.o
	aarch64-linux-gnu-ld -nostdlib -Tlinker.ld boot.o kernel.o -o $@

run: $(KERNEL)
	qemu-system-aarch64 -machine virt -cpu cortex-a57 -kernel $< -nographic

clean:
	@rm -f $(KERNEL) *.o
