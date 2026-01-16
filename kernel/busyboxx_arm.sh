#!/bin/bash

TOOLCHAIN_VERSION=15.2.rel1
KERNEL_VERSION=6.12.65
BUSYBOX_VERSION=1.37.0

# arm toolchain
wget https://developer.arm.com/-/media/Files/downloads/gnu/$TOOLCHAIN_VERSION/binrel/arm-gnu-toolchain-$TOOLCHAIN_VERSION-x86_64-arm-none-linux-gnueabihf.tar.xz
tar -xf arm-gnu-toolchain-$TOOLCHAIN_VERSION-x86_64-arm-none-linux-gnueabihf.tar.xz
mv arm-gnu-toolchain-$TOOLCHAIN_VERSION-x86_64-arm-none-linux-gnueabihf arm-gnu-toolchain

# busyboxx/src
mkdir src && cd src

# kernel
KERNEL_MAJOR=$(echo $KERNEL_VERSION | sed 's/\([0-9]*\)[^0-9].*/\1/')
wget https://www.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz
tar -xf linux-$KERNEL_VERSION.tar.xz

# busyboxx/src/linux-x.xx.xx
cd linux-$KERNEL_VERSION

make ARCH=arm \
  CROSS_COMPILE=../../arm-gnu-toolchain/bin/arm-none-linux-gnueabihf- \
  defconfig
make ARCH=arm \
  CROSS_COMPILE=../../arm-gnu-toolchain/bin/arm-none-linux-gnueabihf- \
  -j$(nproc) || {
  echo "Something went wrong"
  exit 1
}

cd .. # busyboxx/src

# user space: busybox
wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
# src/busybox-1.3x.x
cd busybox-$BUSYBOX_VERSION

# apply patch for arm build
patch -p1 <../../patches/busybox-1.37.0-fix-sha1.patch
# configure
make ARCH=arm \
  CROSS_COMPILE=../../arm-gnu-toolchain/bin/arm-none-linux-gnueabihf- \
  defconfig
sed 's/^#CONFIG_STATIC .*$/CONFIG_STATIC=y/1' -i .config
# build
make ARCH=arm \
  CROSS_COMPILE=../../arm-gnu-toolchain/bin/arm-none-linux-gnueabihf- \
  -j$(nproc) || {
  echo "Something went wrong"
  exit 1
}

# busyboxx/initrd
mkdir -p ../../initrd/{bin,sbin,etc,proc,sys,usr/{bin,sbin}}

make ARCH=arm \
  CROSS_COMPILE=../../arm-gnu-toolchain/bin/arm-none-linux-gnueabihf- \
  CONFIG_PREFIX=../../initrd \
  -j$(nproc) install

cd .. # busyboxx/src
cd .. # busyboxx

# busyboxx/init
cd initrd

cat <<EOF >init
#!/bin/sh

mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
sysctl -w kernel.printk="2 4 1 7"

echo -e "\nWelcome to Minimal Linux distro!\n"

/linuxrc
EOF

chmod +x init

# initrd image
find . -print0 |
  cpio --null -ov --format=newc |
  gzip -9 >../initrd.img.gz

cd .. # busyboxx/

# kernel image to boot OS
cp src/linux-$KERNEL_VERSION/arch/arm/boot/zImage .

qemu-system-arm -M virt \
  -m 256M \
  -kernel zImage \
  -initrd initrd.img.gz \
  -append "root=/dev/mem console=ttyAMA0" \
  -nographic
