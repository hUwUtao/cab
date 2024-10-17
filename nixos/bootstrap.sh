#!/bin/bash
set -euo pipefail

# Check if current directory is /etc/nixos
[[ "$(pwd)" != "/etc/nixos" ]] && { cd /etc/nixos || { echo "Error: Unable to change to /etc/nixos"; exit 1; }; }

# Ensure btrfs-progs and cryptsetup are available
for cmd in btrfs cryptsetup; do
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd not found. Installing..."
        nix-env -iA nixos.$cmd || { echo "Error installing $cmd"; exit 1; }
    fi
done

DISK="$1"
[[ -z "$DISK" ]] && { echo "Error: No disk parameter provided."; echo "Usage: $0 <disk>"; exit 1; }

# Validate disk input
[[ ! -b "$DISK" ]] && { echo "Error: Invalid disk device. Please enter a valid block device."; exit 1; }

# Create file systems
echo "Creating file systems..."
mkfs.fat -F 32 -n CABEFI "${DISK}1" -I || { echo "Error creating EFI partition"; exit 1; }
mkswap -L CABSWAP "${DISK}2" -f || { echo "Error creating swap partition"; exit 1; }

# Setup LUKS encryption for root partition
echo "Setting up LUKS encryption for root partition..."
LUKS_KEY_PATH="/etc/nixos/luks.key"
CABDEPLOYFS_PATH="/etc/nixos/luks.key"
[[ ! -f "$LUKS_KEY_PATH" ]] && { [[ -f "$CABDEPLOYFS_PATH" ]] && cp "$CABDEPLOYFS_PATH" "$LUKS_KEY_PATH" || { echo "Error: LUKS key not found"; exit 1; }; }
cryptsetup luksFormat "${DISK}3" "$LUKS_KEY_PATH" -q --label CABSECROOT || { echo "Error setting up LUKS encryption"; exit 1; }
cryptsetup open "${DISK}3" cryptroot --key-file "$LUKS_KEY_PATH" || { echo "Error opening LUKS partition"; exit 1; }

# Create BTRFS filesystem on encrypted partition
mkfs.btrfs -L CABROOT /dev/mapper/cryptroot -f || { echo "Error creating root partition"; exit 1; }

# Mount partitions
echo "Mounting partitions..."
mount -m /dev/mapper/cryptroot /mnt && {
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@nix
    umount /mnt
} || { echo "Error creating subvolumes"; exit 1; }

mount -m -o subvol=@,noatime /dev/mapper/cryptroot /mnt || { echo "Error mounting @ subvolume"; exit 1; }
mkdir -p /mnt/{boot,nix,etc/nixos}
mount -m /dev/disk/by-label/CABEFI /mnt/boot || { echo "Error mounting boot partition"; exit 1; }
mount -m -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix || { echo "Error mounting @nix subvolume"; exit 1; }
mount -m /dev/disk/by-label/CABDEPLOYFS /mnt/etc/nixos 2>/dev/null || true

# Enable swap
echo "Enabling swap..."
swapon "${DISK}2" || { echo "Error enabling swap"; exit 1; }

# Generate and save UUID to /BUILD file
echo "Generating and saving UUID..."
uuidgen > /mnt/BUILD || { echo "Error creating /BUILD file"; exit 1; }

# Install NixOS
echo "Installing NixOS..."
nixos-install --no-root-passwd || { echo "Error installing NixOS"; exit 1; }

echo "NixOS installation complete. You can now reboot into your new system."
