#!/bin/sh

dd if=/dev/zero of=tmp.img iflag=fullblock bs=1M count=100 && sync

losetup loop30 tmp.img

mkfs -t ext4 /dev/loop30

mkdir /mnt/rpi-disk

mount /dev/loop30 /mnt/rpi-disk

dd if=/dev/loop30 of=rpi.img


umount /dev/loop30

rm tmp.img

