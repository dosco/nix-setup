#!/bin/sh

if [ -z "${SECURE_KEY}" ]; then
    echo '$SECURE_KEY not set'
    exit 1
fi

# Create partition table
parted /dev/vda --script -- mklabel msdos

# Create 1G boot partition
parted /dev/vda --script -- mkpart primary ext4 2048s 1G
# Make rest of it one partition
parted /dev/vda --script -- mkpart primary btrfs 1G 100%

# Encrypt it with given passphrase
echo -n $SECURE_KEY | cryptsetup luksFormat /dev/vda2 -
# Open the encrypted disk
echo -n $SECURE_KEY | cryptsetup luksOpen /dev/vda2 rootPartition -

# Create VG out of encrypted partition
vgcreate nixvg /dev/mapper/rootPartition
# Define 1G swap partition
lvcreate -L 1G -n swap nixvg
# Make rest of the disk single partition
lvcreate -l '100%FREE' -n root nixvg

# Format and enable the swap
mkswap /dev/nixvg/swap
swapon /dev/nixvg/swap

# Format the root disk as btrfs and mount it
mkfs.btrfs -L nixos /dev/nixvg/root
mount /dev/nixvg/root /mnt

# Format the boot partition as ext4
mkfs.ext4 /dev/vda1

# Create boot directory and mount boot partition
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot

# Generate the configuration. We'll use the hardware config.
nixos-generate-config --root /mnt

# Put our configs :)
cp ./nixos/* /mnt/etc/nixos/

# And ...
nixos-install

