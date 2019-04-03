#!/bin/sh

nproc="4"

ARCH="arm"

cd raspberry-pi-uboot/

make clean

make ROSS_COMPILE=arm-linux-gnu- ARCH=arm rpi_2_defconfig
make ROSS_COMPILE=arm-linux-gnu- ARCH=arm -j$(nproc)


cd ..
