#!/bin/sh

SOURCE="sources"

if [ -d ${SOURCE} ];
then
rm -r $SOURCE
fi

mkdir $SOURCE

git clone https://github.com/arjuncr/light-os.git
 
git clone --depth=1 https://github.com/arjuncr/linux ./$SOURCE/linux

git clone --depth=1 https://github.com/arjuncr/raspberry-pi-uboot.git ./$SOURCE/uboot

mv  light-os/* $SOURCE/

rm -r light-os
