#!/bin/bash
set -euo pipefail

DISK="/dev/sdc"
LUKS_KEY_PATH="/etc/nixos/luks.key"

echo "Attaching and decrypting disk at $DISK..."

# Check if the disk exists
if [ ! -b "$DISK" ]; then
    echo "Error: Disk $DISK not found."
    exit 1
fi

# Check if the LUKS key file exists
if [ ! -f "$LUKS_KEY_PATH" ]; then
    echo "Error: LUKS key file not found at $LUKS_KEY_PATH."
    exit 1
fi

# Decrypt the LUKS partition
echo "Decrypting LUKS partition..."
cryptsetup open "$DISK" cryptroot --key-file "$LUKS_KEY_PATH" --verbose

# Mount the decrypted partition
echo "Mounting partitions..."
mount -o subvol=@,noatime /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,nix,etc/nixos}
mount /dev/disk/by-label/CABEFI /mnt/boot
mount -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount /dev/disk/by-label/CABDEPLOYFS /mnt/etc/nixos

# Enable swap
swapon /dev/disk/by-label/CABSWAP

echo "Disk successfully attached, decrypted, and mounted for NixOS installation."
