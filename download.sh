#!/bin/sh

rm -r sources

git clone https://github.com/arjuncr/light-os.git

mkdir sources

git clone --depth=1 https://github.com/arjuncr/linux ./sources/linux

mv  light-os/* sources/

rm -r light-os
