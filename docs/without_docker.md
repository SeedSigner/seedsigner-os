## Building without docker

If you are not using the docker image, then these build tools will be required for cross-compiling with Buildroot. This is only tested and expected to work on a debian based OS using apt package manager (not MacOS). This single command will install required dependencies for a debian based linux os.

```bash
sudo apt update && sudo apt install make binutils build-essential gcc g++ patch gzip bzip2 perl tar cpio unzip rsync file bc libssl-dev dosfstools
```

Then to build to image(s), run the build script passing in the desired options

```bash
cd opt
./build.sh --pi0
```

You can see the different build options with `./build.sh --help`
