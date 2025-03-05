echo "You need the latest QEMU version to get raspi4b"
~/git/qemu/build/qemu-system-aarch64 -machine raspi4b -cpu cortex-a72 -m 2G -S -s -kernel out/kernel8.elf -serial stdio