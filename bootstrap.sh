#!/bin/sh

if [ -z "${SECURE_KEY}" ]; then
    echo '$SECURE_KEY not set'
    exit 1
fi

# Create partition table
parted /dev/vda -- mklabel msdos

# Create 2G boot partition
parted /dev/vda -- mkpart primary ext4 1MiB 2GiB

# Make rest of it one partition
#parted /dev/vda -- mkpart primary btrfs 2GiB -3GiB
parted /dev/vda -- mkpart primary btrfs 2GiB 100%

# Make 3G swap partition
#parted /dev/vda -- mkpart primary linux-swap -3GiB 100%

# Encrypt it with given passphrase
echo -n $SECURE_KEY | cryptsetup luksFormat /dev/vda2
# Open the encrypted disk
echo -n $SECURE_KEY | cryptsetup luksOpen /dev/vda2 enc-pv

# Create VG out of encrypted partition
pvcreate /dev/mapper/enc-pv
vgcreate vg /dev/mapper/enc-pv

# Define 1G swap partition
lvcreate -L 3G -n swap vg
# Make rest of the disk single partition
lvcreate -l '100%FREE' -n root vg

# Format and enable the swap
mkswap -L swap /dev/vg/swap
swapon /dev/vg/swap

# Format the boot partition as fat
# and create boot directory and mount boot partition
mkfs.ext4 /dev/vda1
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot

# Format the root disk as btrfs and mount it
mkfs.btrfs -f -L root /dev/vg/root
mount /dev/vg/root /mnt

# Generate the configuration. We'll use the hardware config.
nixos-generate-config --root /mnt

# Put our configs :)
#cp ./nixos/* /mnt/etc/nixos/

# And ...
#nixos-install

