<p align="center">
  <a href="https://seedsigner.com/">
    <img alt="Gitea" src="docs/img/logo.png" width="90"/>
  </a>
</p>
<h1 align="center">SeedSigner OS</h1>

<p align="center">
  <a href="https://opensource.org/licenses/MIT" title="License: MIT">
    <img src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>
  <a href="" title="Twitter">
  <img src="https://img.shields.io/twitter/follow/seedsigner?style=social">
  </a>
</p>


# ✅ About

A custom linux based operating system built to manage software running on airgapped Bitcoin signing device. SeedSigner is both the project name and [application](http://github.com/SeedSigner/seedsigner/) running on airgapped hardware. This custom operating system, like all operating systems, manages the hardware resources and provides them to the application code. It's currently designed to run on common Raspberry Pi hardware with [accessories](https://github.com/SeedSigner/seedsigner/#shopping-list). The goal of SeedSigner OS is to provide an easy, fast, and secure way to build microSD card image to securely run [SeedSigner](https://seedsigner.com) code.


## ⚙️ Under the Hood

SeedSigner OS is built using [Buildroot](https://www.buildroot.org). Buildroot is a simple, efficient and easy-to-use tool to generate embedded Linux systems through cross-compilation. SeedSigner OS does not fork Buildroot, but uses Buildroot with custom configurations to build microSD card images tailor made for running SeedSigner.


## 🛂 Security

SeedSigner OS is built to reduce the attack surface area and enable additional application functionality. The OS is an order of magnatude smaller in size than Raspberry Pi OS (which is what typically is used to run software on a Pi device). Here are a list of some security and functional advantages of using SeedSigner OS.

- Boots 100% from RAM. This means, once you see the SeedSigner splash screen, you can remove the microSD card because no disk I/O is needed after boot!
- One FAT32 partition on the microSD card
- Removes these standard Raspberry Pi OS Kernel modules:
   - Networking and Bluetooth
   - SWAP
   - I2C
   - Serial
   - USB
   - Pulse-Width Modulation (PWM)
- NO HDMI support
- NO Serial connection TTL support
- NO Software supporting any wireless or networking chips
- A single read only zImage file on the boot partition containing the entire Linux kernel and filesystem


# 🛠 Building

## 🐳 Using Docker

Easiest way to build SeedSigner OS is using docker. This keeps the build process repeatable and the build system clean.

### Build Dependencies

* [Docker Compose](https://docs.docker.com/compose/install/)
* [Docker](https://docs.docker.com/get-docker/)

### Steps to build using docker-compose

- Clone the repository in your machine:
  ```bash
  git clone --recursive https://github.com/SeedSigner/seedsigner-os.git
  ```
2. Go into the repo directory:
  ```bash
  cd seedsigner-os
  ```
3. Build images using docker-compose (expect this to take more than 1 hour). You can change the `--pi0` option to the board type you wish to build or use `--all` to build all images types.
  ```bash
  SS_ARGS="--pi0" docker-compose up -d
  ```

This command will build a docker image from the Dockerfile and in the background (as a daemon) run a container used to compile SeedSigner OS. You can monitor the seedsigner-os-build-images container in Docker Dashboard (if using Docker Desktop) or by running the docker contain list command waiting for the container to complete with an Exit (0) status. The container will create the image(s) in the images directory.

  ```bash
  docker container list --all
  ```

Run ```SS_ARGS="--help" docker-compose up``` to see the possible build options you can pass in via the SS_ARGS env variable.

### Image Location and Naming

By default, the docker-compose.yml is configured to create a container volume to the images directory in the repo. This is where all the image files are written out after the container completes building the OS from source. The images are named following this convension:

`seedsigner_os.<app_repo_branch>.<board_config>.img.gz`

Example name for a pi0 built off the 0.5.2 branch would be named:

`seedsigner_os.0.5.2.pi0.img.gz`

Here is a table Raspberry Pi boards to image filenames/configs

| Board                 | Image Name                        |
| --------------------- | --------------------------------- |
|Raspberry Pi Zero      |`seedsigner_os.<tag>.pi0.img.gz`   |
|Raspberry Pi Zero W    |`seedsigner_os.<tag>.pi0.img.gz`   |
|Raspberry Pi 2 Model B |`seedsigner_os.<tag>.pi2.img.gz`   |
|Raspberry Pi Zero 2 W  |`seedsigner_os.<tag>.pi02w.img.gz` |
|Raspberry Pi 3 Model B |`seedsigner_os.<tag>.pi02w.img.gz` |
|Raspberry Pi 4 Model B |`seedsigner_os.<tag>.pi4.img.gz`   |


## 📑 Using Debian/Ubuntu (without docker)

If you are not using the docker image, then these build tools will be required for cross-compiling with Buildroot. This is only tested and expected to work on a debian based OS using apt package manager (not MacOS). This single command will install required dependencies for a debian based linux os.

```bash
sudo apt update && sudo apt install make binutils build-essential gcc g++ patch gzip bzip2 perl tar cpio unzip rsync file bc libssl-dev
```

Then to build to image(s), run the build script passing in the desired options

```bash
cd opt
./build --pi0
```

You can see the different build options with `./build.sh --help`

## Customizing buildroot configurations

See the Buildroot [quick start guide](https://www.buildroot.org/downloads/manual/manual.html#_buildroot_quick_start) first

### Common Buildroot customization commands:

Buildroot:
```bash
make menuconfig
```

Linux Kernel:
```bash
make linux-menuconfig
```

Busybox:
```bash
busybox-menuconfig
```
