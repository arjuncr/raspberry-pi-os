#!/bin/sh

int_build_env()
{

export SCRIPT_NAME="RASPBERRY PI OS"
export SCRIPT_VERSION="1.2"
export LINUX_NAME="LIGHT LINUX PI"
export DISTRIBUTION_VERSION="2019.6"
export IMAGE_NAME="minimal_rpi-${SCRIPT_VERSION}.img"
export BUILD_OTHER_DIR="build_script_for_other"

# BASE
export KERNEL_BRANCH="4.x" 
export KERNEL_VERSION=""
export BUSYBOX_VERSION="1.30.1"
export SYSLINUX_VERSION="6.03"
export UBOOT_VERSION="v2016.09.01"

# EXTRAS
export NCURSES_VERSION="6.1"

# CROSS COMPILE
export ARCH="arm"
export CROSS_GCC="arm-linux-gnueabihf-"
export MCPU="cortex-a7"

export BASEDIR=`realpath --no-symlinks $PWD`
export SOURCEDIR=${BASEDIR}/light-os
export ROOTFSDIR=${BASEDIR}/rootfs
export IMGDIR=${BASEDIR}/img
export RPI_BOOT=${BASEDIR}/rpi_boot
export UBOOT_DIR=${BASEDIR}/raspberry-pi-uboot
export RPI_KERNEL_DIR=${BASEDIR}/linux
export CONFIG_ETC_DIR="${BASEDIR}/os-configs/etc"

export CFLAGS=-m64
export CXXFLAGS=-m64
export JFLAG=16

export CROSS_COMPILE=$BASEDIR/cross-gcc/arm-linux-gnueabihf/bin/$CROSS_GCC

}

prepare_dirs () {
    cd ${BASEDIR}
    if [ ! -d ${SOURCEDIR} ];
    then
        mkdir ${SOURCEDIR}
    fi
    if [ ! -d ${ROOTFSDIR} ];
    then
        mkdir ${ROOTFSDIR}
    fi
    if [ ! -d ${IMGDIR} ];
    then
        mkdir    ${IMGDIR}
	mkdir -p ${IMGDIR}/bootloader
	mkdir -p ${IMGDIR}/boot
	mkdir -p ${IMGDIR}/boot/overlay
	mkdir -p ${IMGDIR}/kernel
    fi
}

build_kernel () {
    cd ${RPI_KERNEL_DIR}
	
    if [ "$1" == "-c" ]
    then		    
    	make clean -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
    elif [ "$1" == "-b" ]
    then	    
    	make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE bcm2709_defconfig
    	make -j$JFLAG  ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE zImage modules dtbs
    
    	make modules_install

    	cp arch/arm/boot/dts/*.dtb            $IMGDIR/boot/
    	cp arch/arm/boot/dts/overlays/*.dtb*  $IMGDIR/boot/overlays/
    	cp arch/arm/boot/dts/overlays/README  $IMGDIR/booot/overlays/
    	cp arch/arm/boot/zImage               $IMGDIR/kernel/rpi-kernel.img
    fi   
}

build_busybox () {
    cd ${SOURCEDIR}

    cd busybox-${BUSYBOX_VERSION}

    if [ "$1" == "-c" ]
    then	    
    	make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE clean
    elif [ "$1" == "-b" ]
    then	    
    	make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE defconfig
    sed -i 's|.*CONFIG_STATIC.*|CONFIG_STATIC=y|' .config
    	make  ARCH=$arm CROSS_COMPILE=$CROSS_COMPIL busybox \
        	-j ${JFLAG}

    	make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE install \
        	-j ${JFLAG}

    	rm -rf ${ROOTFSDIR} && mkdir ${ROOTFSDIR}
    cd _install
    	cp -R . ${ROOTFSDIR}
    	rm  ${ROOTFSDIR}/linuxrc
    fi
}

build_uboot () {
	cd $UBOOT_DIR
        
	if [ "$1" == "-c" ]
	then       	
		make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE distclean
        elif [ "$1" == "-b" ]
	then	
		make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE rpi_defconfig
		make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE u-boot.bin
		cp u-boot.bin $IMGDIR/bootloader
	else
	     echo "Command Not Supported"
        fi
}

build_extras () {
    #build_ncurses
    cd ${BASEDIR}/${BUILD_OTHER_DIR}
    if [ "$1" == "-c" ]
    then
    	./build_other_main.sh --clean
    elif [ "$1" == "-b" ]
    then
    	./build_other_main.sh --build	    
    fi	    
}

generate_rootfs () {	
    cd ${ROOTFSDIR}
    rm -f linuxrc

    mkdir dev
    mkdir etc
    mkdir proc
    mkdir src
    mkdir sys
    mkdir var
    mkdir var/log
    mkdir srv
    mkdir lib
    mkdir root
    mkdir boot
    mkdir tmp && chmod 1777 tmp

    mkdir -pv usr/{,local/}{bin,include,lib{,64},sbin,src}
    mkdir -pv usr/{,local/}share/{doc,info,locale,man}
    mkdir -pv usr/{,local/}share/{misc,terminfo,zoneinfo}      
    mkdir -pv usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}
    mkdir -pv etc/rc{0,1,2,3,4,5,6,S}.d
    mkdir -pv etc/init.d
    mkdir -pv etc/sys_init

    cd etc
    
    cp $CONFIG_ETC_DIR/motd .

    cp $CONFIG_ETC_DIR/hosts .
  
    cp $CONFIG_ETC_DIR/resolv.conf .

    cp $CONFIG_ETC_DIR/fstab .

    rm -r init.d/*

    install -m ${CONFMODE} ${BASEDIR}/${BOOT_SCRIPT_DIR}/rc.d/init.d/functions     init.d/functions
    install -m ${CONFMODE} ${BASEDIR}/${BOOT_SCRIPT_DIR}/rc.d/init.d/network	   init.d/network
    install -m ${MODE}     ${BASEDIR}/${BOOT_SCRIPT_DIR}/rc.d/startup              sys_init/startup
    install -m ${MODE}     ${BASEDIR}/${BOOT_SCRIPT_DIR}/rc.d/shutdown             init.d/shutdown

    chmod +x init.d/*

    ln -s init.d/network   rc0.d/K01network
    ln -s init.d/network   rc1.d/K01network
    ln -s init.d/network   rc2.d/S01network
    ln -s init.d/network   rc3.d/S01network
    ln -s init.d/network   rc4.d/S01network
    ln -s init.d/network   rc5.d/S01network
    ln -s init.d/network   rc6.d/K01network
    ln -s init.d/network   rcS.d/S01network
	
    cp $CONFIG_ETC_DIR/inittab .

    cp $CONFIG_ETC_DIR/group .

    cp $CONFIG_ETC_DIR/passwd .

    cd ${ROOTFSDIR}
    
    cp $CONFIG_ETC_DIR/init .

    chmod +x init

    #creating initial device node
    mknod -m 622 dev/console c 5 1
    mknod -m 666 dev/null c 1 3
    mknod -m 666 dev/zero c 1 5
    mknod -m 666 dev/ptmx c 5 2
    mknod -m 666 dev/tty c 5 0
    mknod -m 666 dev/tty1 c 4 1
    mknod -m 666 dev/tty2 c 4 2
    mknod -m 666 dev/tty3 c 4 3
    mknod -m 666 dev/tty4 c 4 4
    mknod -m 444 dev/random c 1 8
    mknod -m 444 dev/urandom c 1 9
    mknod -m 666 dev/ram b 1 1
    mknod -m 666 dev/mem c 1 1
    mknod -m 666 dev/kmem c 1 2
    chown root:tty dev/{console,ptmx,tty,tty1,tty2,tty3,tty4}

    # sudo chown -R root:root .
    find . | cpio -R root:root -H newc -o | gzip > ${ISODIR}/rootfs.gz
}

generate_image () {
	echo "Not implimented"
}

test_qemu () {
    cd ${BASEDIR}
    if [ -f ${IMAGE_NAME} ];
    then
	qemu-system-arm -kernel kernel_qemu/kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -hda ${IMAGE_NAME}
    fi
    exit 1
}

clean_files () {
    rm -rf ${SOURCEDIR}
    rm -rf ${ROOTFSDIR}
    rm -rf ${ISODIR}
    rm -rf ${RPI_BOOT}
    rm -rf ${IMGDIR}
    rm -rf ${UBOOT_DIR}
    rm -rf ${RPI_KERNEL_DIR}
    
}

init_work_dir()
{
prepare_dirs
}

clean_work_dir()
{
clean_files
}

build_all()
{
build_kernel  -b
build_busybox -b
build_uboot   -b
build_other   -b
}

rebuild_all()
{
clean_all
build_all
}

clean_all()
{
build_kernel  -c
build_busybox -c
build_uboot   -c
build_other   -c
}

wipe_rebuild()
{
clean_work_dir
init_work_dir
rebuild_all
}

help_msg()
{
echo -e "#################################################################################\n"

echo -e "############################Utility to Build RPI OS##############################\n"

echo -e "#################################################################################\n"

echo -e "Help message --help\n"

echo -e "Build All: --build-all\n"

echo -e "Rebuild All: --rebuild-all\n"

echo -e "Clean All: --clean-all\n"

echo -e "Wipe and rebuild --wipe-rebuild\n" 

echo -e "Building kernel: --build-kernel --rebuild-kernel --clean-kernel\n"

echo -e "Building busybx: --build-busybox --rebuild-busybox --clean-busybox\n"

echo -e "Building uboot: --build-uboot --rebuild-uboot  --clean-uboot\n"

echo -e "Building other soft: --build-other --rebuild-other --clean-other\n"

echo -e "Creating root-fs: --create-rootfs\n"

echo -e "Create ISO Image: --create-img\n"

echo -e "Cleaning work dir: --clean-work-dir\n"

echo -e "Test with Qemu --Run-qemu\n"

echo "###################################################################################"

}

option()
{

if [ -z "$1" ]
then
help_msg
exit 1
fi

if [ "$1" == "--build-all" ]
then	
build_all
fi

if [ "$1" == "--rebuild-all" ]
then
rebuild_all
fi

if [ "$1" == "--clean-all" ]
then
clean_all
fi

if [ "$1" == "--wipe-rebuild" ]
then
wipe_rebuild
fi

if [ "$1" == "--build-kernel" ]
then
build_kernel -b
elif [ "$1" == "--rebuild-kernel" ]
then
build_kernel -r
elif [ "$1" == "--clean-kernel" ]
then
build_kernel -c
fi

if [ "$1" == "--build-busybox" ]
then
build_busybox -b
elif [ "$1" == "--rebuild-busybox" ]
then
build_busybox -r
elif [ "$1" == "--clean-busybox" ]
then
build_busybox -c
fi

if [ "$1" == "--build-uboot" ]
then
build_uboot -b
elif [ "$1" == "--rebuild-uboot" ]
then
build_uboot -r
elif [ "$1" == "--clean-uboot" ]
then
build_uboot -c
fi

if [ "$1" == "--build-other" ]
then
build_other -b
elif [ "$1" == "--rebuild-other" ]
then
build_other -r
elif [ "$1" == "--clean-other" ]
then
build_other -c
fi

if [ "$1" == "--create-rootfs" ]
then
generate_rootfs
fi

if [ "$1" == "--create-img" ]
then
generate_image
fi

if [ "$1" == "--clean-work-dir" ]
then
clean_work_dir
fi

if [ "$1" == "--Run-qemu" ]
then
test_qemu
fi

}

main()
{
int_build_env
init_work_dir
option $1
}

#starting of script
main $1 

