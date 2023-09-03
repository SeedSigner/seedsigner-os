# Building a SeedSigner SD card image
Assemble the SeedSigner OS along with the SeedSigner application code into an image file that can be flashed to an SD card and run in your SeedSigner.
<br/>
<br/>
<br/>
## 🔥🔥🔥🛠 Quickstart: SeedSigner Reproducible Build! 🛠🔥🔥🔥

### Install Docker
* Desktop: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* Linux command line: [Docker Engine](https://docs.docker.com/engine/install/#server)


### Launch the build
<details><summary>macOS/Linux:</summary>
<p>

```bash
# Copy the SeedSigner OS repo to your local machine
git clone --recursive https://github.com/SeedSigner/seedsigner-os.git

# Move into the repo directory
cd seedsigner-os

# Must build w/amd64 platform to get identical result, even if your actual cpu is different (e.g. M1 Mac is arm64)
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```

Select your board type from the [Board configs](#board-configs) list below. 

If you're unsure, most people should specify `pi0`.

```bash
# Set your board type
export BOARD_TYPE=pi0
```

Building will take 25-30 minutes and will require 20-30 GB of disk space.
```bash
# Launch the Docker container and start building
SS_ARGS=--$BOARD_TYPE docker compose up --force-recreate --build
```
</p>
</details>

<details><summary>Windows:</summary>
<p>

* [Install `git`](https://git-scm.com/download/win)

Open a PowerShell terminal

```bash
# TODO: how to set and invoke env vars in Windows?
```

```powershell
# Copy the SeedSigner OS repo to your local machine
git clone --recursive https://github.com/SeedSigner/seedsigner-os.git

# Move into the repo directory
cd seedsigner-os

# Must build w/amd64 platform to get identical result, even if your actual cpu is different (e.g. M1 Mac is arm64)
#export DOCKER_DEFAULT_PLATFORM=linux/amd64
```


...

</p>
</details>



<br/>
<br/>

---

## Detailed information
Easiest way to build SeedSigner OS is using docker. This keeps the build process repeatable and the build system clean.


### Steps to build using docker compose

1. Clone the repository in your machine:
Do this with a recursive clone to pull the buildroot submodule at the same time. By default, this will create a directory in the current working directory named seedsigner-os.
   ```bash
   git clone --recursive https://github.com/SeedSigner/seedsigner-os.git
   ```
3. Go into the repo directory:
   ```bash
   cd seedsigner-os
   ```
4. Build the images using docker compose (expect this to take more than 1 hour). It *will* require 20-30 GB of disk space. You can change the `--pi0` option to the board type you wish to build or use `--all` to build all images types. The `export DOCKER_DEFAULT_PLATFORM=linux/amd64` is required to make the build reproducible. If you leave out this option on a ARM64 mac it will build faster. The `--force-recreate` and `--build` options are specified to make sure the latest image and container are used (not a local one cached).
   ```bash
   export DOCKER_DEFAULT_PLATFORM=linux/amd64
   SS_ARGS="--pi0" docker compose up --force-recreate --build
   ```

This command will build a docker image from the Dockerfile and in the background (as a daemon) run a container used to compile SeedSigner OS. You can monitor the seedsigner-os-build-images container in Docker Dashboard (if using Docker Desktop) or by running the docker container list command while waiting for the container to complete with an Exit (0) status. The container will create the image(s) in the images directory.

  ```bash
  docker container list --all
  ```

Run ```SS_ARGS="--help" docker compose up``` to see the possible build options you can pass in via the SS_ARGS env variable.

### Image Location and Naming

By default, the docker-compose.yml is configured to create a container volume of the *images* directory in the repo. This is where all the image files are written out after the container completes building the OS from source. That volume is accessible from the host. The image files are named using this convention:

`seedsigner_os.<app_repo_branch>.<board_config>.img`

Example name for a pi0 built off the 0.5.2 branch would be named:

`seedsigner_os.0.5.2.pi0.img`

Here is a table of Raspberry Pi boards to image filenames/configs


### Board configs
| Board                 | Image Name                        | Build Script Option |
| --------------------- | --------------------------------- | ------------------- |
|Raspberry Pi Zero      |`seedsigner_os.<tag>.pi0.img`      | --pi0               |
|Raspberry Pi Zero W    |`seedsigner_os.<tag>.pi0.img`      | --pi0               |
|Raspberry Pi 2 Model B |`seedsigner_os.<tag>.pi2.img`      | --pi2               |
|Raspberry Pi Zero 2 W  |`seedsigner_os.<tag>.pi02w.img`    | --pi02w             |
|Raspberry Pi 3 Model B |`seedsigner_os.<tag>.pi02w.img`    | --pi02w             |
|Raspberry Pi 4 Model B |`seedsigner_os.<tag>.pi4.img`      | --pi4               |

