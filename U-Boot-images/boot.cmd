#
# flash-kernel: bootscr.paz00
#

echo === Toshiba AC100 MMC autoboot ===

setenv devtype mmc
setenv devnum 0
setenv rootpart 1
setenv distro_rootpart ${rootpart}
setenv prefix /
setenv vmlinuz vmlinuz
setenv dtb dtb
setenv initrd initrd.img.gzu
setenv systemroot mmcblk1p2
setenv delayprerun 5

setenv bootargs  cgroup_enable=memory cgroup_memory=1 root=/dev/${systemroot} console=ttyS0,115200n8 console=tty1
setenv initrd_high ''
setenv fdt_high ''
load ${devtype} ${devnum}:${rootpart} ${kernel_addr_r} ${prefix}${vmlinuz}
load ${devtype} ${devnum}:${rootpart} ${ramdisk_addr_r} ${prefix}${initrd}
load ${devtype} ${devnum}:${rootpart} ${fdt_addr_r} ${prefix}${dtb}
echo bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
echo delay ${delayprerun} ... Press Ctrl-C to interrupt.
sleep ${delayprerun}
bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
