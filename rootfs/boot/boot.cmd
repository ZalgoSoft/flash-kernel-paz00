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
#NB:Needs newline after UBOOT_ENV_EXTRA macro 
## some failsafe checks
if test "${devtype}" = ""
then
  setenv devtype mmc
else
  echo devtype "${devtype}"
fi
if test "${devnum}" = ""
then
  setenv devnum 0
else
  echo devnum "${devnum}"
fi
if test "${rootpart}" = ""
then
  setenv rootpart 1
else
  echo rootpart "${rootpart}"
fi
if test "${prefix}" = ""
then
  setenv prefix /
else
  echo prefix "${prefix}"
fi
if test "${vmlinuz}" = ""
then
  setenv vmlinuz vmlinuz
else
  echo vmlinuz "${vmlinuz}"
fi
if test "${initrd}" = ""
then
  setenv initrd initrd.img.gzu
else
  echo initrd "${initrd}"
fi
## some failsafe checks end

setenv bootargs  quiet splash root=/dev/${systemroot} console=ttyS0,115200n8 console=tty1
setenv initrd_high ''
setenv fdt_high ''
load ${devtype} ${devnum}:${rootpart} ${kernel_addr_r} ${prefix}${vmlinuz}
load ${devtype} ${devnum}:${rootpart} ${ramdisk_addr_r} ${prefix}${initrd}
load ${devtype} ${devnum}:${rootpart} ${fdt_addr_r} ${prefix}${dtb}
echo bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
echo delay ${delayprerun} ... Press Ctrl-C to interrupt.
sleep ${delayprerun}
bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
