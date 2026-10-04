NASM = nasm
QEMU = C:/Users/DanielFenech/QEMU/qemu-system-x86_64.exe

BUILD = build

BOOT_SOURCES = \
	boot/boot.asm \
	boot/kickstart.asm

KERNEL_SOURCES = \
	kernel/kernel.asm \
	kernel/drivers/video/vga.asm

BOOT_BIN = $(BUILD)/boot.bin
KERNEL_BIN = $(BUILD)/kernel.bin
IMAGE = $(BUILD)/septadisk.img

.PHONY: all run clean

all: $(IMAGE)

$(BUILD):
	mkdir -p $(BUILD)

$(BOOT_BIN): $(BOOT_SOURCES) | $(BUILD)
	$(NASM) -f bin boot/boot.asm -o $(BOOT_BIN)

$(KERNEL_BIN): $(KERNEL_SOURCES) | $(BUILD)
	$(NASM) -f bin kernel/kernel.asm -o $(KERNEL_BIN)

$(IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
	cat $(BOOT_BIN) $(KERNEL_BIN) > $(IMAGE)

run: $(IMAGE)
	$(QEMU) -drive file=$(IMAGE),format=raw,if=ide -boot c

clean:
	rm -rf $(BUILD)