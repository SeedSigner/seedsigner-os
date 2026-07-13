# Development images

The `-dev` images exist to make it convenient to develop SeedSigner *on the device itself*. They run the same application, from the same buildroot environment, with the same libraries as the release images with additions to aid in development conveniences. **They are not security-hardened: networking and SSH are enabled. Never use a dev image with real funds.**

This doc is the **reference** for what the developer images contain and how they're configured. For the hands-on side — the quick start, syncing your code, controlling the app, and running the tests — see [dev_workflow.md](dev_workflow.md).

Available for all four boards: `pi0`, `pi02w`, `pi2`, and `pi4`. Throughout this doc, paths written as `<board>-dev/...` refer to the board you're building for (e.g. `pi0-dev/board/post-build.sh`).

## How the dev image stays close to the release image

The dev board config deliberately *references* the release files and layers a delta on top, so release changes flow into the dev image automatically:

| Piece | Release base | Dev delta |
|---|---|---|
| kernel config | `../<board>/board/kernel.config` | `<board>-dev/board/kernel.config.fragment` |
| busybox config | `../<board>/board/busybox.config` | `<board>-dev/board/busybox.config.fragment` |
| rootfs overlay | `../rootfs-overlay/` | `../rootfs-overlay-dev/` (applied second) |
| defconfig | copied from `<board>_defconfig` | dev packages appended at the bottom |
| post-build | derived from release script | skips the image-slimming steps |

Each board's dev config bases on **its own** release `kernel.config` / `busybox.config` (so `pi0-dev` uses `../pi0/...`, `pi4-dev` uses `../pi4/...`, and so on) plus a small board-specific fragment. The kernel fragments are almost identical across boards; the notable exceptions are documented inline in each fragment (the Pi Zero / Zero W needs `CONFIG_PM` + `CONFIG_RASPBERRYPI_POWER` and an explicit `CONFIG_USB` to power its USB block, and the Pi 4 needs the SD-card voltage regulators or `/dev/mmcblk0` never appears).

Like the release image, the dev image boots entirely from an initramfs (the root filesystem lives in RAM). Persistence is provided by a second partition (see below).

## What's added

- **Networking**: onboard wifi (Zero 2 W / Pi 3 / Pi 4), any `eth*` USB ethernet adapter, and the Pi 2/3/4's onboard NIC. Everything is DHCP.
- **USB relay**: `dtoverlay=dwc2` plus a built-in `g_ether` gadget. Plug the Pi's USB **OTG** port into a computer and it shows up as an "RNDIS/Ethernet Gadget" at a fixed `10.55.0.1`, so `ssh root@10.55.0.1` works immediately with no host-side configuration. This requires an OTG-capable port: the micro-USB **data** port on the Pi Zero / Zero W / Zero 2 W, or the **USB-C** power port on the Pi 4. The Pi 2 / Pi 3 Model B route USB through an onboard hub with no exposed OTG, so on those boards use the onboard Ethernet (or a USB wifi/ethernet adapter) instead. If you also want the Pi to reach the internet over the cable, turn on internet sharing on the host (see [seedsigner docs/usb_relay.md](https://github.com/SeedSigner/seedsigner/blob/dev/docs/usb_relay.md) for host-side setup — the SD-card-side steps there are *not* needed, the dev image is preconfigured) — the Pi detects the host's DHCP server and uses that instead of its static address. See "USB relay networking" below.
- **SSH server** (dropbear): log in as `root` with the root password below, or drop an `authorized_keys` file on the boot partition. Host keys persist on the data partition, so no fingerprint warnings after reboots.
- **HDMI console + USB keyboard/mouse**: a root shell runs on `tty1`.
- **Persistent storage**: a 256MB ext4 partition (label `seedsigner-data`) mounted at `/mnt/data`, **auto-grown to fill the rest of the microSD on first boot** (so a 32GB card gives you ~32GB of `/mnt/data`). Because the whole OS runs from RAM, you can pull the microSD while the device is running (`/mnt/data` disappears, everything else keeps working) and reinsert it later — `/mnt/data` auto-remounts, no reboot needed. Run `sync` before pulling the card if you have unsaved writes.
- **CLI tools**: `git`, `gh`, `rsync`, `ssh`/`scp`/`sftp` (OpenSSH client), `vi` (busybox), `nano`, `wget`, `ip`/`ifconfig`/`ping`/`nslookup`, `pip` (with setuptools), plus `bash`, `tmux`, `htop`, `strace`, `gdb`, `jq`, and more. The full python stdlib (including `unittest`) is kept, and all `.py` sources stay readable on-device instead of `.pyc`-only. See "Installing Python packages" below for the pip/venv specifics.

## Building the developer SeedSigner OS Image

Set `BOARD_TYPE` to the board you're building for — one of `pi0`, `pi02w`, `pi2`, or `pi4`:

```bash
export BOARD_TYPE=pi0

SS_ARGS="--${BOARD_TYPE} --dev" docker compose up --build
```

or from a shell inside the container:

```bash
./build.sh --${BOARD_TYPE} --dev
```

The image lands in `images/seedsigner_os.<branch>.${BOARD_TYPE}-dev.img`. Once you've built it, head to [dev_workflow.md](dev_workflow.md#quick-start-macos) to flash it and start developing.

## Using the image

### Wifi credentials

Put a `wifi.txt` on the boot partition (the FAT volume you see when you insert the SD card into your computer, also visible on-device at `/mnt/microsd`):

```
MyNetworkName
MyPassphrase
US        <- optional country code, defaults to US
```

Power cycle. If you need more control (hidden SSID, enterprise auth, multiple networks), provide a full `wpa_supplicant.conf` on the boot partition instead.

### Root password

`seedsigner`. This is set in `<board>-dev_defconfig` (`BR2_TARGET_GENERIC_ROOT_PASSWD`) and reapplied by `<board>-dev/board/post-build.sh` — see the comments there if you change it, since the release rootfs-overlay's `etc/shadow` would otherwise silently overwrite it back to a locked account.

### Finding the device / SSH

The image runs an mDNS/Zeroconf responder (`mdnsd`), so from any machine on the same link you can just use its `.local` name — no need to hunt for the IP:

```bash
ssh root@seedsigner.local
```

This works over the USB relay, wifi, and ethernet alike, and follows whatever address DHCP hands out (mdnsd re-checks every 10s). macOS and Linux (with nss-mdns/avahi) resolve `.local` out of the box; on Windows it needs Bonjour installed. If `.local` resolution isn't available, run `network-info` from the HDMI console (or check your router/DHCP leases) and `ssh root@<ip>` instead.

The advertised name is `seedsigner` (set in `/etc/default/mdnsd`). The system hostname is `seedsigner-os` — the same as the release image, which the SeedSigner app requires (it keys OS-specific behavior, such as storing settings on the microSD and detecting card insert/removal, off the hostname).

The image is **IPv4-only** — IPv6 is disabled via `ipv6.disable=1` on the kernel command line (`<board>-dev/board/boot_cmdline.txt`). Without this the USB-relay link picks up a link-local/ULA IPv6 that `ssh root@seedsigner.local` would try first and stall on before falling back to IPv4; with IPv6 off, `seedsigner.local` resolves to the IPv4 address only and plain `ssh root@seedsigner.local` connects directly.

### USB relay networking

Plug the Pi into a computer over its USB OTG port (see the board table under [USB relay](#whats-added) — the Zero-family micro-USB data port or the Pi 4 USB-C port; not available on the Pi 2/3 Model B). Within a few seconds:

- If the host is **not** sharing its internet connection, the Pi assigns itself `10.55.0.1` and runs a small DHCP server (`udhcpd`, range `10.55.0.2`–`10.55.0.6`), so the host auto-configures its side of the link too. Just `ssh root@10.55.0.1`.
- If the host **is** sharing its internet connection (macOS: System Settings → General → Sharing → Internet Sharing, share to the "RNDIS/Ethernet Gadget"/USB interface), the Pi detects the host's DHCP server instead and takes a normal lease from it (typically `192.168.2.x` on macOS), giving the Pi an actual internet route for `git clone`/`pip`/etc. The lease address can change between reboots — this is exactly why `ssh root@seedsigner.local` (see above) is the easiest way in. Otherwise find the address with `network-info`, or on the host: `arp -a | grep bridge100` (macOS).

### Installing Python packages

`pip` is included, so `python3 -m pip install <package>` works once the device has internet (over wifi or the USB relay with host internet sharing). Two things to keep in mind:

- **The root filesystem runs from RAM**, so a plain `python3 -m pip install <pkg>` lands in `/usr/lib/python3*/site-packages` and is **lost on reboot**. For anything you want to keep, install onto the data partition instead — either into a venv there, or with `python3 -m pip install --target=/mnt/data/pylibs <pkg>` and add that dir to `PYTHONPATH`.
- **There is no C compiler on the device** (Buildroot cross-compiles). pip can install pure-Python packages and any prebuilt `armv7l` (`manylinux`) wheels, but a package that has to compile C from an sdist will fail.
- **Don't reinstall the app's compiled dependencies with pip.** Pillow and numpy are C-extension packages already baked into the image; `python3 -m pip install -r requirements.txt` would try to *build* them and fail on the missing compiler (e.g. Pillow's "headers or library files could not be found for zlib"). Instead, make the venv see the image's copies with `--system-site-packages` (below) — pip then reports them already satisfied and skips them. (`embit` and `pyzbar` are pure-Python and *can* be pip-installed — see the embit example below for testing a newer version — but they're baked in too, so a normal setup doesn't need to.)

Virtualenvs: on this image `python3 -m venv DIR` is customized to do the right thing by default — it **includes the system site-packages** (so the venv sees the baked-in Pillow/numpy/embit/…) and **skips the pip bootstrap** (python is built `--without-ensurepip`; the system pip is used instead). So just:

```bash
python3 -m venv /mnt/data/seedsigner/venv
. /mnt/data/seedsigner/venv/bin/activate
python3 -m pip install <package>       # installs into the active venv
```

(Upstream CPython defaults are the opposite — isolated, with a bundled pip; the defaults are flipped in `<board>-dev/board/post-build.sh` because neither upstream default is usable here. A `venv` at `/mnt/data/seedsigner/venv` is also what `start.sh` uses to launch the app — see [Developing on the device](dev_workflow.md#developing-on-the-device).)

### Example: testing a newer version of a baked-in library (embit)

Some of the app's dependencies — `embit`, `Pillow`, `numpy`, `pyzbar` — are baked into the image as system packages under `/usr/lib/python3/site-packages/`, which you can't edit in place (the rootfs runs from RAM). To try a **newer version of a pure-Python one like `embit`** without rebuilding the image, install it into your `--system-site-packages` venv: the venv's `site-packages` comes first on `sys.path`, so the copy you install there **shadows** the baked-in one. And since `seedsigner restart` launches the app through the venv's python, it picks up the shadowed version automatically.

The device needs internet for this (USB relay with Internet Sharing on, or wifi). In your checkout's venv:

```bash
cd /mnt/data/seedsigner
source venv/bin/activate

# latest release from PyPI, installed into the venv (shadows the system embit)
python3 -m pip install --upgrade embit

# ...or a specific tagged release straight from git (any tag, branch, or commit
# after the @):
# python3 -m pip install --upgrade 'git+https://github.com/diybitcoinhardware/embit.git@v0.8.1'

# confirm the venv copy is the one that now loads, and its version (embit has no
# embit.__version__, so read the version from the installed package metadata)
python3 -c "import importlib.metadata as m, embit; print(m.version('embit'), embit.__file__)"
#   -> X.Y.Z  /mnt/data/seedsigner/venv/lib/python3.12/site-packages/embit/__init__.py

seedsigner restart      # the app now runs against the new embit
pytest                  # and/or run the suite
```

pip installs into the venv (the writable location), so you'll see a harmless `Not uninstalling embit at /usr/lib/python3/site-packages, outside environment` notice — it's leaving the baked-in copy in place and layering the new one on top. Revert to the image's version any time with:

```bash
python3 -m pip uninstall embit
```

Notes:

- If pip says `Requirement already satisfied` (PyPI's latest matches the baked-in version), force it into the venv with an explicit version or `--ignore-installed`: `python3 -m pip install 'embit==0.9.0'`.
- This shadowing trick only works for **pure-Python** packages. One with a compiled C extension (`Pillow`, `numpy`, ...) can't be pip-built on the device (no compiler), so a newer version of those has to go through a Buildroot image rebuild — bump the version + hash in `opt/external-packages/python-<pkg>/`.

### Clock

The Pi has no RTC. The dev image sets a plausible recent date at boot (so TLS/`git clone` work) and corrects it via NTP once it has internet access.
