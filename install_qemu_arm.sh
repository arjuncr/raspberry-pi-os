#!/bin/sh

QEMU="3.1.0"

wget https://download.qemu.org/qemu-$QEMU.tar.xz

tar xvJf qemu-$QEMU.tar.xz

cd qemu-$QEMU
./configure --target-list=arm-softmmu,arm-linux-user
make -j 2
sudo make install
