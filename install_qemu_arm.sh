#!/bin/sh

QEMU="3.1.0"

if [ "$1" == "-c" ]
then
        if [ -f qemu-$QEMU.tar.xz ]
        then
                rm qemu-$QEMU.tar.xz
        fi
        if [ -d qemu-$QEMU ]
        then
                rm -r qemu-$QEMU
        fi
fi

if [ ! -f qemu-$QEMU.tar.xz ]
then
	wget https://download.qemu.org/qemu-$QEMU.tar.xz
	if [ ! -d qemu-$QEMU ]
	then	
		tar xvJf qemu-$QEMU.tar.xz
	fi
else
	if [ ! -d qemu-$QEMU ]
        then
        	tar xvJf qemu-$QEMU.tar.xz
        fi
fi

cd qemu-$QEMU
	make clean
	./configure --target-list=arm-softmmu,arm-linux-user
	make -j 4 
	make install

