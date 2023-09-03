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

Windows users may also need to [install `git`](https://git-scm.com/download/win)



### Launch the build
In a terminal window:

```bash
# Copy the SeedSigner OS repo to your local machine
git clone --recursive https://github.com/SeedSigner/seedsigner-os.git

# Move into the repo directory
cd seedsigner-os
```

Force Docker to build on amd64 in order to get an identical result, even if your actual cpu is different (e.g. M1 Mac is arm64):

<table>
    <tr>
        <td width="40%">macOS / Linux:

```bash
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```

</td>
<td width="40%">Windows:

```powershell
set DOCKER_DEFAULT_PLATFORM=linux/amd64
```
</td>
</tr>
</table>

Select your board type from the [Board configs](#board-configs) list below. 

If you're unsure, most people should specify `pi0`.

<table>
    <tr>
        <td width="40%">macOS / Linux:

```bash
export BOARD_TYPE=pi0
```
</td>
        <td width="40%">Windows:(?)

```powershell
set BOARD_TYPE=pi0
```
</td>
</tr>
</table>


Building can take 25min to 2.5hrs+ depending on your cpu and will require 20-30 GB of disk space.
<table>
    <tr>
        <td width="40%">macOS / Linux:

```bash
SS_ARGS=--$BOARD_TYPE docker compose up --force-recreate --build
```

</td>
        <td width="40%">Windows:(?)

```powershell
SS_ARGS=--%BOARD_TYPE% docker compose up --force-recreate --build
```
</td>
</tr>
</table>


When the build completes you'll see:

_TODO: Update with v0.7.0 release hash_
```bash
seedsigner-os-build-images-1  | /opt/buildroot
seedsigner-os-build-images-1  | 7a8fa1a81fb2145ea5d71d35b54bd425479ad5095fe52ce6bd14fefae1e4f47e  /opt/../images/seedsigner_os.dev.pi0.img
seedsigner-os-build-images-1 exited with code 0
```

The completed image file will be in the `images` subdirectory.
```bash
cd images
ls -l
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

