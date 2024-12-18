# Development cycle using docker

Each time the `docker compose up` command runs, a full build from scratch is performed. You can optionally run `docker compose up -d` in detached mode by adding the `-d` flag. This will run the container in the background. To have faster development cycles you'll likely want to avoid building the OS from scratch each time. To avoid recreating the docker image/container each time, you have a few different routes. One such route is to pass the options `--no-op` (which is the default) to the `SS_ARGS` env variable when running `docker-compose up`. This will cause the container to skip the build steps but keep the container running in the background until you explicitly stop it. You can then launch a shell session into the container and work interactively, running any specific build commands you desire.

Using docker compose will start the container (create new container if one does not already exist) without building an image
```bash
SS_ARGS="--no-op" docker compose up -d --no-recreate
```

If you want to start a new container environment, use `--force-recreate` instead of `--no-create`
```bash
SS_ARGS="--no-op" docker compose up -d --force-recreate --build
```

Start a shell session inside the container by running
```bash
docker exec -it seedsigner-os-build-images-1 bash
```

Once you are in the container you can use the build script directly from the `/opt` directory
```bash
./build.sh --pi0 --app-repo=https://github.com/seedsigner/seedsigner.git --app-branch=dev --no-clean
```

or

```bash
./build.sh --pi0 --app-repo=https://github.com/seedsigner/seedsigner.git --app-commit-id=9c36f5c --no-clean
```

Or you can use any of the Buildroot customization commands like `make menuconfig` or `linux-menuconfig`  from the `/output` directory

Move images manually built with `make` with the command `mv images/seedsigner_os.img /images/`


## "Disk full" troubleshooting
If your build fails with the following:
```
The partition table has been altered.
Syncing disks.
mkfs.fat 4.2 (2021-01-31)
Disk full
make[1]: *** [Makefile:815: target-post-image] Error 1
make: *** [Makefile:23: _all] Error 2
```

You just need to edit the `post-image-seedsigner.sh` script in your target board's `board/` subdir (e.g. opt/pi0/board/). Edit this section:

```
# Create disk image.
dd if=/dev/zero of=disk.img bs=1M count=26 #26 MB
```

Increase the `count` to create a larger disk image and then re-run your build.


## Image Location and Naming

By default, the docker-compose.yml is configured to create a container volume of the *images* directory in the repo. This is where all the image files are written out after the container completes building the OS from source. That volume is accessible from the host. The image files are named using this convention:

`seedsigner_os.<app_repo_branch>.<board_config>.img`

Example name for a `pi0` built off the 0.5.2 branch would be named:

`seedsigner_os.0.5.2.pi0.img`


## Development Configs
Each board also has a developer configuration (dev config). Inside the `/opt` folder are all the build configs for each board matching the name of the build script option. The dev configs are built to work on each board but enable many of the kernel and OS features needed for development. This also makes the built image less secure, so please do not use those with real funds. Dev configs are only used when the `--dev` option is passed in to the build.sh script.