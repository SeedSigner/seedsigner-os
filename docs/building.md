# Building a SeedSigner SD card image
Assemble the SeedSigner OS along with the SeedSigner application code into an image file that can be flashed to an SD card and run in your SeedSigner.
<br/>
<br/>
<br/>
## 🔥🔥🔥🛠 Quickstart: SeedSigner Reproducible Build! 🛠🔥🔥🔥

<details><summary>macOS / Linux instructions:</summary>
<p>

### Install Dependencies
* Docker (choose one):
    * Desktop users: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
    * Or Linux command line: [Docker Engine](https://docs.docker.com/engine/install/#server)

### Launch the build
In a terminal window:

```bash
# Copy the SeedSigner OS repo to your local machine
git clone --recursive https://github.com/SeedSigner/seedsigner-os.git

# Move into the repo directory
cd seedsigner-os

# initialize and update submodules (buildroot)
git submodule init && git submodule update
```

Force Docker to build on a container meant to run on amd64 in order to get an identical result, even if your actual cpu is different:

```bash
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```

Select your board type from the [Board configs](#board-configs) list below. 

If you're unsure, most people should specify `pi0`.

```bash
export BOARD_TYPE=pi0
```

Start the build!

```bash
SS_ARGS="--$BOARD_TYPE --app-branch=0.8.0" docker compose up --force-recreate --build
```

Building can take 25min to 2.5hrs+ depending on your cpu and will require 20-30 GB of disk space.
</p>
</details>


<details><summary>Windows PowerShell instructions:</summary>
<p>
Recommend running these steps in WSL2 (Windows Subsystem for Linux) so that you can just follow the Linux steps below.

### Install Dependencies
* Docker (choose one):
    * Desktop users: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
    * Or Linux command line: [Docker Engine](https://docs.docker.com/engine/install/#server)
* Windows PowerShell users may also need to [install `git`](https://git-scm.com/download/win)

### Launch the build
In a terminal window:

```bash
# Copy the SeedSigner OS repo to your local machine
git clone --recursive https://github.com/SeedSigner/seedsigner-os.git

# Move into the repo directory
cd seedsigner-os

# initialize and update submodules (buildroot)
git submodule init && git submodule update
```

Force Docker to build on a container meant to run on amd64 in order to get an identical result, even if your actual cpu is different:

```powershell
$env:DOCKER_DEFAULT_PLATFORM = 'linux/amd64'
```

Select your board type from the [Board configs](#board-configs) list below. 

If you're unsure, most people should specify `pi0`.

```powershell
$env:BOARD_TYPE = 'pi0'
```

Start the build!

```powershell
# TODO: INCORRECT SYNTAX FOR POWERSHELL(?)
SS_ARGS="--%BOARD_TYPE% --app-branch=0.8.0" docker compose up --force-recreate --build
```

Building can take 25min to 2.5hrs+ depending on your cpu and will require 20-30 GB of disk space.

</p>
</details>
<br>


---

## Build Results
When the build completes you'll see:
```bash
seedsigner-os-build-images-1  | /opt/buildroot
seedsigner-os-build-images-1  | 1d0f1c412f64b40e6aba21b5bacdb41d9323653c170ce06d0a3f1dd71fddb28e  /opt/../images/seedsigner_os.0.8.0.pi0.img
seedsigner-os-build-images-1 exited with code 0
```

The second line above lists the SHA256 hash of the image file that was built. This hash should match the hash of the release image [published on the main github repo](https://github.com/SeedSigner/seedsigner/releases/tag/0.8.0). If the hashes match, then you have successfully confirmed the reproducible build!

The completed image file will be in the `images` subdirectory.
```bash
cd images
ls -l

total 26628
-rw-r--r-- 1 root root       97 Aug 20 14:59 README.md
-rw-r--r-- 1 root root 27262976 Aug 20 14:59 seedsigner_os.0.8.0.pi0.img
```

That image can be burned to an SD card and run in your SeedSigner.




<br/>
<br/>

---


## Board configs
| Board                 | Image Name                        | Build Script Option |
| --------------------- | --------------------------------- | ------------------- |
|Raspberry Pi Zero      |`seedsigner_os.<tag>.pi0.img`      | --pi0               |
|Raspberry Pi Zero W    |`seedsigner_os.<tag>.pi0.img`      | --pi0               |
|Raspberry Pi 2 Model B |`seedsigner_os.<tag>.pi2.img`      | --pi2               |
|Raspberry Pi Zero 2 W  |`seedsigner_os.<tag>.pi02w.img`    | --pi02w             |
|Raspberry Pi 3 Model B |`seedsigner_os.<tag>.pi02w.img`    | --pi02w             |
|Raspberry Pi 4 Model B |`seedsigner_os.<tag>.pi4.img`      | --pi4               |


---


## Hashes for each 0.8.0 build target
| Build | SHA256 Hash | Image Name |
| ----- | ----------- | ---------- |
| pi0   |`1d0f1c412f64b40e6aba21b5bacdb41d9323653c170ce06d0a3f1dd71fddb28e`|  seedsigner_os.0.8.0.pi0.img|
| pi02w |`c8d5352ed4a86c19eb9ef54f2920934f8ce460742b464ea94dc9114f9f4e039a`|  seedsigner_os.0.8.0.pi02w.img|
| pi2   |`11c5553d75b3ebca4988ae3c4573b60b33a12bc4779282454ae34404ba797670`|  seedsigner_os.0.8.0.pi2.img|
| pi4   |`917201e335bfc7ee4189f17827f954f89588dc0fdefdad80d26f2a65c5c8e6d0`|  seedsigner_os.0.8.0.pi4.img|

## Hashes for each 0.7.0 build target
| Build | SHA256 Hash | Image Name |
| ----- | ----------- | ---------- |
| pi0   |`a380cb93eb852254863718a9c000be9ec30cee14a78fc0ec90708308c17c1b8a`|  seedsigner_os.0.7.0.pi0.img|
| pi02w |`fe0601e6da97c7711093b67a7102f8108f2bfb8a2478fd94fa9d3edea5adfb64`|  seedsigner_os.0.7.0.pi02w.img|
| pi2   |`65be9209527ba03efe8093099dae8ec65725c90a758bc98678b9da31639637d7`|  seedsigner_os.0.7.0.pi2.img|
| pi4   |`d574c1326d07e18b550e2f65e36a4678b05db882adb5cb8f8732ff8d75d59809`|  seedsigner_os.0.7.0.pi4.img|
