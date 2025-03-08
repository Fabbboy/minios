CC:=clang
LD:=ld.lld
CP:=cp
OBCOPY:=llvm-objcopy-20

CFLAGS := -target aarch64-none-elf -nostdlib -ffreestanding -mcpu=cortex-a72 -g
ASFLAGS := -target aarch64-none-elf -nostdlib -ffreestanding -mcpu=cortex-a72 -g
LDFLAGS := -nostdlib -nostartfiles -ffreestanding -mcpu=cortex-a72 -g
OBCOPYFLAGS := -O binary

WORKDIR:=$(shell pwd)
KERNEL_DIR:=$(WORKDIR)/kernel
OUT_DIR:=$(WORKDIR)/out
BOOT_DIR:=$(WORKDIR)/boot
FIRMDIR:=$(WORKDIR)/firmware

FIXUP:=$(FIRMDIR)/boot/fixup4.dat
START:=$(FIRMDIR)/boot/start4.elf
OVERLAY:=$(FIRMDIR)/boot/overlays/miniuart-bt.dtbo
CONFIG:=$(WORKDIR)/config.txt
LINKER_SCRIPT:=$(WORKDIR)/linker.ld

ITARGET:=$(OUT_DIR)/kernel8.elf
TARGET:=$(BOOT_DIR)/kernel8.img

C_SOURCES:=$(shell find $(KERNEL_DIR) -name "*.c")
C_OBJECTS:=$(patsubst $(KERNEL_DIR)/%.c, $(OUT_DIR)/%.o, $(C_SOURCES))

ASM_SOURCES:=$(shell find $(KERNEL_DIR) -name "*.S")
ASM_OBJECTS:=$(patsubst $(KERNEL_DIR)/%.S, $(OUT_DIR)/%.o, $(ASM_SOURCES))

all: clean prepare copy $(TARGET)

.PHONY: all clean prepare copy 

clean:
	rm -rf $(OUT_DIR) $(BOOT_DIR)

prepare:
	mkdir -p $(OUT_DIR) $(BOOT_DIR)

copy: prepare
	$(CP) $(FIXUP) $(BOOT_DIR)/fixup4.dat
	$(CP) $(START) $(BOOT_DIR)/start4.elf
	$(CP) $(CONFIG) $(BOOT_DIR)/config.txt
	mkdir -p $(BOOT_DIR)/overlays
	$(CP) $(OVERLAY) $(BOOT_DIR)/overlays/miniuart-bt.dtbo

$(OUT_DIR)/%.o: $(KERNEL_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OUT_DIR)/%.o: $(KERNEL_DIR)/%.S
	$(CC) $(ASFLAGS) -c $< -o $@

$(ITARGET): prepare $(C_OBJECTS) $(ASM_OBJECTS)
	$(LD) $(LDLDFLAGS) -T $(LINKER_SCRIPT) -o $(ITARGET) $(C_OBJECTS) $(ASM_OBJECTS) 

$(TARGET): $(ITARGET)
	$(OBCOPY) $(OBCOPYFLAGS) $(ITARGET) $(TARGET)