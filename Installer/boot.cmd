Ubuntu boot script (disk-based)

setenv devtype mmc

# devnum 1 is for external mmc
setenv devnum 1

# first partition
setenv rootpart 1

setenv distro_rootpart ${rootpart}

# boot.scr must be in root
setenv prefix /

setenv vmlinuz vmlinuz
setenv dtb dtb
setenv initrd initrd.gz

# enables framebuffer
setenv bootargs debian-installer/framebuffer=true console=ttyS0,115200n8 console=tty1

# need for modern u-boot
setenv initrd_high ''
setenv fdt_high ''

load ${devtype} ${devnum}:${rootpart} ${kernel_addr_r} ${prefix}${vmlinuz}
load ${devtype} ${devnum}:${rootpart} ${ramdisk_addr_r} ${prefix}${initrd}

# // same as load ${devtype} ${devnum}:${rootpart} ${fdt_addr_r} ${prefix}${soc}-${board}.dtb
load ${devtype} ${devnum}:${rootpart} ${fdt_addr_r} ${prefix}${dtb}

bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}

