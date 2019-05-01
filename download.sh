#!/bin/sh

SOURCE="sources"
RPI_BOOT="rpi_boot"

if [ -d ${SOURCE} ];
then
rm -r $SOURCE
fi

mkdir $SOURCE

git clone https://github.com/arjuncr/light-os.git
 
git clone --depth=1 https://github.com/arjuncr/linux ./$SOURCE/linux

git clone --depth=1 https://github.com/arjuncr/raspberry-pi-uboot.git ./$SOURCE/uboot

cd $RPI_BOOT
wget https://github.com/arjuncr/firmware/tree/master/boot/bootcode.bin
wget https://github.com/arjuncr/firmware/tree/master/boot/start.elf
cd ..

mv  light-os/* $SOURCE/

rm -r light-os
