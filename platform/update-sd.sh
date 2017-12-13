#!/bin/bash

if [ $# -ne 1 ];then
  echo "You must specify the device to update."
  echo "Example: $0 /dev/sdd1 "
  exit 1
fi

device=$1

# Check that we are root
if [ $(whoami) != "root" ];then
  echo "You must be root"
  exit 1
fi

mount $device /mnt
if [ $? -ne 0 ];then
  echo "Failed to mount $device. Exit"
  exit 1
fi
echo "Mounting $device ok"

rm -f /mnt/*
cp boot/BOOT.bin /mnt
cp linux/devicetree/devicetree.dtb /mnt
cp linux/kernel/uImage /mnt
cp linux/rootfs/uramdisk.image.gz /mnt
echo "Updating $device ok"
sync

umount $device
if [ $? -ne 0 ];then
  echo "Failed to unmount $device. Exit"
  exit 1
fi
echo "Unmounting $device ok"

exit 0
