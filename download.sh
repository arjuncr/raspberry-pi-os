#!/bin/sh

rm -r sources

git clone https://github.com/arjuncr/light-os.git

mkdir sources

git clone --depth=1 https://github.com/arjuncr/linux ./sources/linux

git clone --depth=1 https://github.com/arjuncr/raspberry-pi-uboot.git ./sources/uboot

mv  light-os/* sources/

rm -r light-os
