#!/bin/sh
# ******************************************************************************
# RASPBERRY PI OS - 2019.6
# ******************************************************************************

SCRIPT_NAME="RASPBERRY PI OS"
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

MENU_ITEM_SELECTED=0
DIALOG_OUT=/tmp/dialog_$$

# ******************************************************************************
# DIALOG FUNCTIONS
# ******************************************************************************

show_main_menu () {
    dialog --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "MAIN MENU" \
    --default-item "${1}" \
    --menu "Lets build ${LINUX_NAME} operating Operating System v${SCRIPT_VERSION}" 18 64 10 \
    0 "INTRODUCTION" \
    1 "PREPARE DIRECTORIES AND ENV" \
    2 "BUILD KERNEL" \
    3 "BUILD BUSYBOX" \
    4 "BUILD UBOOT"  \
    5 "BUILD EXTRAS" \
    6 "GENERATE ROOTFS" \
    7 "GENERATE IMAGE" \
    8 "TEST IMAGE IN ARM QEMU" \
    9 "CLEAN FILES" \
    10 "QUIT" 2> ${DIALOG_OUT}
}

show_dialog () {
    if [ ${#2} -le 24 ]; then
    WIDTH=24; HEIGHT=6; else
    WIDTH=64; HEIGHT=14; fi
    dialog --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "${1}" \
    --msgbox "${2}" ${HEIGHT} ${WIDTH}
}

ask_dialog () {
    dialog --stdout \
    --backtitle "${SCRIPT_NAME} - ${DISTRIBUTION_VERSION} / v${SCRIPT_VERSION}" \
    --title "${1}" \
    --yesno "${2}" 14 64
}

check_error_dialog () {
    if [ $? -gt 0 ];
    then
        show_dialog "An error occured ;o" "There was a problem with ${1}.\nCheck the console output. Fix the problem and come back to the last step."
        exit
    fi
}

# ******************************************************************************
# MENUS
# ******************************************************************************

menu_introduction () {
    show_dialog "INTRODUCTION" "${LINUX_NAME} is an light linux based os" \
    && MENU_ITEM_SELECTED=0
    return 0
}

menu_prepare_dirs () {
    ask_dialog "PREPARE DIRECTORIES" "Create empty folders to work with.\n - /sources for all the source code\n - /rootfs for our root tree\n - /img for img file" \
    && prepare_dirs \
    && MENU_ITEM_SELECTED=1 \
    && select_arm_cross_gcc \
    && show_dialog "PREPARE DIRECTORIES" "Done."
    return 0
}

select_arm_cross_gcc () {
	export CROSS_COMPILE=$BASEDIR/cross-gcc/arm-linux-gnueabihf/bin/$CROSS_GCC
}

menu_build_kernel () {
    ask_dialog "BUILD KERNEL" "Linux Kernel ${KERNEL_VERSION} - this is the hearth of the operating system.\n\nRecipe:\n - extract\n - configure\n - build" \
    && build_kernel \
    && MENU_ITEM_SELECTED=2 \
    && show_dialog "BUILD KERNEL" "Done."
    return 0
}
menu_build_busybox () {
    ask_dialog "BUILD BUSYBOX" "Build BusyBox ${BUSYBOX_VERSION} - all the basic stuff like cp, ls, etc.\n\nRecipe:\n - extract\n - configure\n - build" \
    && build_busybox \
    && MENU_ITEM_SELECTED=3 \
    && show_dialog "BUILD BUSYBOX" "Done."
    return 0
}

menu_build_uboot () { 
    ask_dialog "BUILD UBOOT" "Build UBOOT ${UBOOT_VERSION} - all the basic stuff like cp, ls, etc.\n\nRecipe:\n - extract\n - configure\n -build" \
    && build_uboot \
    && MENU_ITEM_SELECTED=4 \
    && show_dialog "BUILD U-BOOT" "Done."
    return 0
}

menu_build_extras () {
    ask_dialog "BUILD EXTRAS" "Build extra soft" \
    && build_extras \
    && MENU_ITEM_SELECTED=5 \
    && show_dialog "BUILD EXTRAS" "Done."
    return 0
}

menu_generate_rootfs () {
    ask_dialog "GENERATE ROOTFS" "Generate root file system. Combines all of the created files in a one directory tree.\n\nRecipe:\n - generates default /etc files (configs).\n - compress file tree" \
    && generate_rootfs \
    && MENU_ITEM_SELECTED=6 \
    && show_dialog "GENERATE ROOTFS" "Done."
    return 0
}

menu_generate_image () {
    ask_dialog "GENERATE IMAGE" "Generate  img file  to boot from.\n\nRecipe: \n - copy nessesary files to rootfs directory\n - build image" \
    && generate_image \
    && MENU_ITEM_SELECTED=7 \
    && show_dialog "GENERATE IMG FILE" "Done."
    return 0
}

menu_qemu () {
    ask_dialog "TEST IMAGE IN QEMU" "Test generated image on emulated computer (QEMU):\n - x86_64\n - 128MB ram\n - cdrom\n\nLOGIN: root\nPASSWORD: root" \
    && test_qemu \
    && MENU_ITEM_SELECTED=8 \
    && show_dialog "TEST IMAGE IN QEMU" "Done."
    return 0
}

menu_clean () {
    ask_dialog "CLEAN FILES" "Remove all archives, sources and temporary files." \
    && clean_files \
    && MENU_ITEM_SELECTED=9 \
    && show_dialog "CLEAN FILES" "Done."
    return 0
}


loop_menu () {
    show_main_menu ${MENU_ITEM_SELECTED}
    choice=$(cat ${DIALOG_OUT})

    case $choice in
        0) menu_introduction && loop_menu ;;
        1) menu_prepare_dirs && loop_menu ;;
        2) menu_build_kernel && loop_menu ;;
        3) menu_build_busybox && loop_menu ;;
	4) menu_build_uboot  && loop_menu ;;
        5) menu_build_extras && loop_menu ;;
        6) menu_generate_rootfs && loop_menu ;;
        7) menu_generate_image && loop_menu ;;
        8) menu_qemu && loop_menu ;;
        9) menu_clean && loop_menu ;;
        10) exit;;
    esac
}

# ******************************************************************************
# MAGIC HAPPENS HERE
# ******************************************************************************

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
			
    make clean

    KERNEL=kernel7

    make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE bcm2709_defconfig

    make -j$JFLAG  ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE zImage modules dtbs
    

    make modules_install

    cp arch/arm/boot/dts/*.dtb            $IMGDIR/boot/
    cp arch/arm/boot/dts/overlays/*.dtb*  $IMGDIR/boot/overlays/
    cp arch/arm/boot/dts/overlays/README  $IMGDIR/booot/overlays/
    cp arch/arm/boot/zImage               $IMGDIR/kernel/rpi-kernel.img

    check_error_dialog "linux${KERNEL_VERSION}"
}

build_busybox () {
    cd ${SOURCEDIR}

    cd busybox-${BUSYBOX_VERSION}

    KERNEL=kernel7

    make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE clean
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

    check_error_dialog "busybox-${BUSYBOX_VERSION}"
}

build_uboot () {
	cd $UBOOT_DIR

	make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE distclean
	make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE rpi_defconfig
	make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE u-boot.bin

	cp u-boot.bin $IMGDIR/bootloader
}

build_extras () {
    #build_ncurses
    cd ${BASEDIR}/${BUILD_OTHER_DIR}
    ./build_other_main.sh

    check_error_dialog "Building extras"

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

    check_error_dialog "rootfs"
}

generate_image () {
	echo "not implimented"
}


test_qemu () {
    cd ${BASEDIR}
    if [ -f ${IMAGE_NAME} ];
    then
	qemu-system-arm -kernel kernel_qemu/kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -hda ${IMAGE_NAME}
    fi
    check_error_dialog "${IMAGE_NAME}"
}

clean_files () {
    sudo rm -rf ${SOURCEDIR}
    sudo rm -rf ${ROOTFSDIR}
    sudo rm -rf ${ISODIR}
    sudo rm -rf ${RPI_BOOT}
    sudo rm -rf ${IMGDIR}
}

# ******************************************************************************
# RUN SCRIPT
# ******************************************************************************

set -ex
loop_menu
set -ex

# ******************************************************************************
# EOF
# ******************************************************************************

