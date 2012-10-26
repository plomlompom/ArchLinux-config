#/bin/sh

# Arch Linux initial installation script as per 2012-10-27 for
# plomlompom's plom-eee system.

# This is where we hope to get the postinstall files from.
URL=http://files.plomlompom.de/postinstall.tar.gz

# Upgrade installation system.
pacman --noconfirm -Syu

# Create/mount new filesystem.
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt

# Install all packages necessary for the first boot.
pacstrap /mnt linux dhcpcd pacman syslinux

# Create swap space; tell fstab about partitions / filesystems.
mkswap /dev/sda1
swapon /dev/sda1
genfstab -p /mnt >> /mnt/etc/fstab

# Empty rc.conf to avoid calling uninstalled daemons.
echo '' > /mnt/etc/rc.conf

# Install, configure SYSLINUX.
arch-chroot /mnt syslinux-install_update -iam
mv /mnt/boot/syslinux/syslinux.cfg temp
cat temp | sed 's@APPEND root=/dev/sda3 ro@APPEND root=/dev/sda3 ro init=/bin/systemd@g' > /mnt/boot/syslinux/syslinux.cfg

# Add ability to boot into Arch Linux on other partition.
echo '
LABEL oldarch
        MENU LABEL Old Arch Linux
        LINUX ../old_vmlinuz-linux
        APPEND root=/dev/sda2 ro
        INITRD ../old_initramfs-linux.img' >> /mnt/boot/syslinux/syslinux.cfg
mkdir /mnt_sda2
mount /dev/sda2 /mnt_sda2
cp /mnt_sda2/boot/vmlinuz-linux /mnt/boot/old_vmlinuz-linux
cp /mnt_sda2/boot/initramfs-linux.img /mnt/boot/old_initramfs-linux.img

# Get post-installation configuration data.
curl $URL > postinstall.tar.gz
tar xf postinstall.tar.gz
mv postinstall /mnt/root/

# Finished! Remove installation medium during this step.
reboot
