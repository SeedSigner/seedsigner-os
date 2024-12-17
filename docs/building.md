# Building a SeedSigner SD card image
Assemble the SeedSigner OS along with the SeedSigner application code into an image file that can be flashed to an SD card and run in your SeedSigner.
<br/>
<br/>
<br/>
## 🔥🔥🔥🛠 Quickstart: SeedSigner Reproducible Build! 🛠🔥🔥🔥

### Install Dependencies
* Docker (choose one):
    * Desktop users: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
    * Or Linux command line: [Docker Engine](https://docs.docker.com/engine/install/#server)
* Windows PowerShell users may also need to [install `git`](https://git-scm.com/download/win)

### Clone the SeedSigner OS repo
In a terminal window:

```bash
# Copy the SeedSigner OS repo to your local machine
git clone --recursive https://github.com/SeedSigner/seedsigner-os.git

# Move into the repo directory
cd seedsigner-os

# initialize and update submodules (buildroot)
git submodule init
git submodule update
```

---

### Configure and begin the build
<details><summary>macOS / Linux instructions:</summary>
<p>


#### Configure environment variables
Force Docker to build on a container meant to run on amd64 in order to get an identical result, even if your actual cpu is different:

```bash
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```

Select your board type from the [Board configs](#board-configs) list below. 

If you're unsure, most people should specify `pi0`.

```bash
export BOARD_TYPE=pi0
```

Set your target release version of the SeedSigner code (see: https://github.com/SeedSigner/seedsigner/releases):

```bash
# e.g. 0.8.0, 0.7.0, etc
export RELEASE_TAG=x.y.z
```


#### Start the build!
```bash
SS_ARGS="--$BOARD_TYPE --app-branch=$RELEASE_TAG" docker compose up --force-recreate --build
```
</p>
</details>


<details><summary>Windows PowerShell instructions:</summary>
<p>
*Note: We recommend running these steps in WSL2 (Windows Subsystem for Linux) instead of PowerShell so that you can just follow the macOS / Linux steps above.*

#### Configure environment variables
Force Docker to build on a container meant to run on amd64 in order to get an identical result, even if your actual cpu is different:

```powershell
$env:DOCKER_DEFAULT_PLATFORM = 'linux/amd64'
```

Select your board type from the [Board configs](#board-configs) list below. 

If you're unsure, most people should specify `pi0`.

```powershell
$env:BOARD_TYPE = 'pi0'
```

Set your target release version of the SeedSigner code (see: https://github.com/SeedSigner/seedsigner/releases):

```powershell
# e.g. "0.8.0", "0.7.0", etc
$env:RELEASE_TAG = "x.y.z"  
```

#### Start the build!
```powershell
$env:SS_ARGS = "--$env:BOARD_TYPE --app-branch=$env:RELEASE_TAG"
docker compose up --force-recreate --build
```

</p>
</details>
<br>

Building can take 25min to 2.5hrs+ depending on your cpu and will require 20-30 GB of disk space.


## Build Results
When the build completes you'll see:
```bash
seedsigner-os-build-images-1  | /opt/buildroot
seedsigner-os-build-images-1  | {image hash}  /opt/../images/seedsigner_os.{RELEASE_TAG}.{BOARD_TYPE}.img
seedsigner-os-build-images-1 exited with code 0
```

The second line above will show the SHA256 hash of the image file that was built. This hash should match the hash of the release image [published on the main github repo](https://github.com/SeedSigner/seedsigner/releases) for the chosen `RELEASE_TAG` + `BOARD_TYPE` combo. If the hashes match, then you have successfully confirmed the reproducible build!

The completed image file will be in the `images` subdirectory.
```bash
cd images
ls -l

total 26628
-rw-r--r-- 1 root root       97 Sep 11 02:09 README.md
-rw-r--r-- 1 root root 27262976 Sep 11 18:49 seedsigner_os.{RELEASE_TAG}.{BOARD_TYPE}.img
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
|Build all targets      |(all of the above)                 | --all               |
