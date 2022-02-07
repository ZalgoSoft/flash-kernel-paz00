#!/bin/bash
R=2
BOOTPART=1

if [ -n "$1" ]
        then
                echo "unmount"
                cd /tmp/
                umount /tmp/$R/dev
                umount /tmp/$R/proc
                umount /tmp/$R/sys
                umount /tmp/$R/boot
                umount /tmp/$BOOTPART
                umount /tmp/$R
                df -h |grep mmc

        else
                echo "mount"
                mkdir /tmp/1
                mkdir /tmp/2
                mkdir /tmp/3
                mkdir /tmp/4
                mount /dev/mmcblk1p1  /tmp/1
                mount /dev/mmcblk1p2  /tmp/2
                mount /dev/mmcblk1p3  /tmp/3
                mount /dev/mmcblk1p4  /tmp/4
                mount -obind /dev /tmp/$R/dev
                mount -obind /proc /tmp/$R/proc
                mount -obind /sys /tmp/$R/sys
                mount -obind /tmp/$BOOTPART  /tmp/$R/boot
                cd /tmp/$R
                df -h |grep mmc
fi
