#!/bin/sh
# ******************************************************************************
# RASPBERRY PI OS - 2019.4
# ******************************************************************************

SCRIPT_NAME="RASPBERRY PI OS"
SCRIPT_VERSION="1.0"
export LINUX_NAME="LIGHT LINUX PI"
export DISTRIBUTION_VERSION="2019.2"
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
export SOURCEDIR=${BASEDIR}/sources
export ROOTFSDIR=${BASEDIR}/rootfs
export IMGDIR=${BASEDIR}/img
export RPI_BOOT=rpi_boot

export CFLAGS="-march=native -O2 -pipe"
export CXXFLAGS="-march=native -O2 -pipe"
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
        mkdir ${IMGDIR}
    fi
}

build_kernel () {
    cd ${SOURCEDIR}
			
    cd linux${KERNEL_VERSION}
      
    make clean

    KERNEL=kernel7

    make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE bcm2709_defconfig

    make -j$JFLAG  ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE zImage modules dtbs
    

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
	cd ${SOURCEDIR}
	cd uboot

	KERNEL=kernel7

	make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE distclean
	make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE rpi_defconfig
	make -j$JFLAG ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE u-boot.bin

	cp u-boot.bin ${ROOTFSDIR}
}

build_extras () {
    #build_ncurses
    cd ${BASEDIR}/${BUILD_OTHER_DIR}
    ./build_other_main.sh

    check_error_dialog "Building extras"

}

build_ncurses () {
    cd ${SOURCEDIR}
    
    cd ncurses-${NCURSES_VERSION}
    
    if [ -f Makefile ] ; then
        make -j ${JFLAG} clean
    fi
    sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
    CFLAGS="${CFLAGS}" ./configure \
        --prefix=/usr \
        --with-termlib \
        --with-terminfo-dirs=/lib/terminfo \
        --with-default-terminfo-dirs=/lib/terminfo \
        --without-normal \
        --without-debug \
        --without-cxx-binding \
        --with-abi-version=5 \
        --enable-widec \
        --enable-pc-files \
        --with-shared \
        CPPFLAGS=-I$PWD/ncurses/widechar \
        LDFLAGS=-L$PWD/lib \
        CPPFLAGS="-P"

    make -j ${JFLAG} ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE install -j ${JFLAG}  \
        DESTDIR=${ROOTFSDIR}
    check_error_dialog "ncurses-${NCURSES_VERSION}"
}

build_nano () {
    cd ${SOURCEDIR}

    cd nano-${NANO_VERSION}
    if [ -f Makefile ] ; then
            make -j ${JFLAG} clean
    fi
    CFLAGS="${CFLAGS}" ./configure \
        --prefix=/usr \
        LDFLAGS=-L$PWD/lib

    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE -j ${JFLAG}
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE install -j ${JFLAG} \
        DESTDIR=${ROOTFSDIR}

    check_error_dialog "nano-${NANO_VERSION}"
}

build_vim () {
    cd ${SOURCEDIR}

    cd vim${VIM_DIR}
    if [ -f Makefile ] ; then
            make -j ${JFLAG} clean
    fi
    CFLAGS="${CFLAGS}" ./configure \
        --prefix=/usr \
        LDFLAGS=-L$PWD/lib

    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE -j ${JFLAG}
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE install \
        -j ${JFLAG} \
        DESTDIR=${ROOTFSDIR}

    check_error_dialog "vim-${VIM_VERSION}"
}


generate_rootfs () {
    cd ${ROOTFSDIR}
    rm -f linuxrc

    mkdir dev
    mkdir etc
    mkdir proc
    mkdir src
    mkdir sys
    mkdir tmp && chmod 1777 tmp

    cd etc
    touch motd
    echo >> motd
    echo ' ------------------------------------ 2019.2 ' >> motd
    echo '                   "..^__                    ' >> motd
    echo '                   *,,-,_).-~                ' >> motd
    echo '                 LIGHT LINUX PI              ' >> motd
    echo '                                             ' >> motd
    echo '  ------------------------------------------ ' >> motd
    echo >> motd

    touch bootscript.sh
    echo '#!/bin/sh' >> bootscript.sh
    echo 'dmesg -n 1' >> bootscript.sh
    echo 'mount -t devtmpfs none /dev' >> bootscript.sh
    echo 'mount -t proc none /proc' >> bootscript.sh
    echo 'mount -t sysfs none /sys' >> bootscript.sh
    echo >> bootscript.sh
    chmod +x bootscript.sh

    touch inittab
    echo '::sysinit:/etc/bootscript.sh' >> inittab
    echo '::restart:/sbin/init' >> inittab
    echo '::ctrlaltdel:/sbin/reboot' >> inittab
    echo '::once:cat /etc/motd' >> inittab
    echo '::askfirst:-/bin/login' >> inittab
    echo 'tty2::once:cat /etc/motd' >> inittab
    echo 'tty2::askfirst:-/bin/sh' >> inittab
    echo 'tty3::once:cat /etc/motd' >> inittab
    echo 'tty3::askfirst:-/bin/sh' >> inittab
    echo 'tty4::once:cat /etc/motd' >> inittab
    echo 'tty4::askfirst:-/bin/sh' >> inittab
    echo >> inittab

    touch group
    echo 'root:x:0:root' >> group
    echo >> group

    touch passwd
    echo 'root:R.8MSU0Z/1ttM:0:0:Light Linux,,,:/root:/bin/sh' >> passwd
    echo >> passwd

    cd ${ROOTFSDIR}

    touch init
    echo '#!/bin/sh' >> init
    echo 'exec /sbin/init' >> init
    echo >> init
    chmod +x init

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

