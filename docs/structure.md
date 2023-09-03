## SeedSignerOS Layers

Kernel and User space are all built from scratch.

![Image Showing SeedSignerOS Layers](docs/img/ssos_layers.png?raw=true "SeedSignerOS Layers")

1. First layer is the hardware. Normally this is the Raspberry Pi board, camera, LCD Waveshare HAT, and microSD card.
2. Second layer is the linux kernel. Using Buildroot, only specific and minimum required modules have been hand selected to use in the kernel. This layer is required to make use of hardware functionality.
3. Third layer is user space. This is where all the libraries and applications reside. The SeedSigner application lives in this space. This is also where libraries typically live to do networking, display drivers, external port communications, etc. However on SeedSignerOS, none of these drivers or libraries are loaded (that are typically found in a linux OS).

## How is the .iso structured?

![SeedSignerOS microSD File Structure](docs/img/ssos_sd_files.png?raw=true "SeedSignerOS microSD File Structure")

The zImage a compressed version of the Linux kernel that is self-extracting. In that compressed image, we added RootFS. The entire system in a single file!

## Boot Sequence

1. When Raspberry Pi is powered on, the bootloader starts on GPU and reads the MicroSD (SDRAM disabled at this point)
2. GPU reads bootcode.bin and starts the bootloader to enable SDRAM
3. Then start_x.elf reads config.txt, cmdline.txt and kernel
4. CPU starts working and then boots the kernel

![Boot Sequence](docs/img/ssos_boot_seq.png?raw=true "Boot Sequence")

Source: https://raspberrypi.stackexchange.com/questions/10442/what-is-the-boot-sequence
