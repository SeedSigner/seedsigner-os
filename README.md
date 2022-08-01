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


## ✅ Purpose

The goal of this project is to make the easiest, fastest, safer and most painless way to build a custom OS that runs <a href="https://seedsigner.com">SeedSigner</a>. For that reason we have pick <a href="https://www.buildroot.org">Buildroot</a>.

## 🛂 Security
1. **SeedSigner OS boots from RAM**. So, once you see the SeedSigner splash screen, you can release the MicroSD and keep using the device!
2. **No** /rootfs partition on MicroSD
3. Many Kernel modules disabled by default:
  - Networking and Bluetooth
  - SWAP
  - I2C
  - Serial
  - USB
  - Pulse-Width Modulation (PWM)
  - ...
4. **NO** HDMI
5. **NO** Serial connection TTL
6. **NO** Software that can try to use or access to the wireless, audio, RF...
7. We will have only **/boot** partition in our MicroSD. In which is located a zImage file **(read-only)** that contains the Linux Kernel and RootFS
8. Images are not reproducible. Unique hash in every compilation
9. ...

## 🛠 Building

#### 🔧 Steps to build an image:
1. Clone the repository in your machine:
```bash
git clone --recursive https://github.com/SeedSigner/seedsigner-os.git
```
2. Go to the work directory:
```bash
cd seedsigner-os/build_workdir/
```
3. Use ./builder to build the image:
```bash
./builder -i
```

The final image **seedsigner_os.img** is going to be located under **build_workdir/images/**

### ℹ️ ./builder help
You can see the different build options with `./builder -h`

## 📝 <a href="https://www.buildroot.org/downloads/manual/manual.html#_buildroot_quick_start">See and modify configurations</a>
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

## 📑 <a href="https://www.buildroot.org/downloads/manual/manual.html#requirement">Requirements</a>
Because we are cross-compiling with Buildroot, we need certains tools for that task.
Usually, Debian based OS have all dependences already installed by default. But using this command you can install the main packages in case needed:

```bash
sudo apt update && sudo apt install make binutils build-essential gcc g++ patch gzip bzip2 perl tar cpio unzip rsync file bc
```
