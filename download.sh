#!/bin/sh

SOURCE="sources"
RPI_BOOT="rpi_boot"

if [ -d ${SOURCE} ];
then
rm -r $SOURCE
fi

mkdir $SOURCE

if [ -d ${RPI_BOOT} ]
then
rm -r  $RPI_BOOT
fi

mkdir $RPI_BOOT

if [ -d light-os ]
then 
rm -r light-os
fi

git clone https://github.com/arjuncr/light-os.git
 
git clone --depth=1 https://github.com/arjuncr/linux ./$SOURCE/linux

git clone --depth=1 https://github.com/arjuncr/raspberry-pi-uboot.git ./$SOURCE/uboot

cd $RPI_BOOT
wget https://github.com/arjuncr/firmware/tree/master/boot/bootcode.bin
wget https://github.com/arjuncr/firmware/tree/master/boot/start.elf
cd ..

mv  light-os/* $SOURCE/

rm -r light-os
