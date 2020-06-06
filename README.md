Minimal os for raspberry pi with uboot.


For cloning the repo.

git clone --recurse-submodules https://github.com/arjuncr/raspberry-pi-os.git

Update existing repo to latest.

git pull

git submodule update

Building the os from source: (./build_rpi_os.sh) 

```
#################################################################################

########################1.7 Utility to Build RPI OS##############################

#################################################################################

Help message --help

Build All: --build-all

Rebuild All: --rebuild-all

Clean All: --clean-all

Wipe and rebuild --wipe-rebuild

Building kernel: --build-kernel --rebuild-kernel --clean-kernel

Building busybx: --build-busybox --rebuild-busybox --clean-busybox

Building uboot: --build-uboot --rebuild-uboot  --clean-uboot

Building other soft: --build-other --rebuild-other --clean-other

Creating root-fs: --create-rootfs

Create ISO Image: --create-img

Cleaning work dir: --clean-work-dir

Test with Qemu --Run-qemu

###################################################################################

```
