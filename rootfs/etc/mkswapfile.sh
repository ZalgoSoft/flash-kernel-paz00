fallocate -l 300M /swapfile
mkswap /swapfile
echo -e "\n/swapfile                                 none            swap    sw              0       0\n" >> /etc/fstab

