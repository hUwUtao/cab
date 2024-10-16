read -p "Enter the target disk (e.g., /dev/sda): " DISK

# Validate disk input
if [ ! -b "$DISK" ]; then
    echo "Error: Invalid disk device. Please enter a valid block device."
    exit 1
fi

# Create file systems
echo "Creating file systems..."
mkfs.fat -F 32 -n CABEFI "${DISK}1" -I || { echo "Error creating EFI partition"; exit 1; }
mkfs.btrfs -L CABROOT "${DISK}3" -f || { echo "Error creating root partition"; exit 1; }
mkswap -L CABSWAP "${DISK}2" -f || { echo "Error creating swap partition"; exit 1; }

# Mount partitions
echo "Mounting partitions..."
mount -m "${DISK}3" /mnt || { echo "Error mounting root partition"; exit 1; }
btrfs subvolume create /mnt/@ || { echo "Error creating @ subvolume"; exit 1; }
btrfs subvolume create /mnt/@nix || { echo "Error creating @nix subvolume"; exit 1; }
umount /mnt

mount -m -o subvol=@ "${DISK}3" /mnt || { echo "Error mounting @ subvolume"; exit 1; }
mkdir -p /mnt/{boot,nix,etc/nixos}
mount -m /dev/disk/by-label/CABEFI /mnt/boot || { echo "Error mounting boot partition"; exit 1; }
mount -m -o subvol=@nix,compress=zstd,noatime "${DISK}3" /mnt/nix || { echo "Error mounting @nix subvolume"; exit 1; }
mount -m /dev/disk/by-label/CABDEPLOYFS /mnt/etc/nixos 2>/dev/null || true

# Enable swap
echo "Enabling swap..."
swapon "${DISK}2" || { echo "Error enabling swap"; exit 1; }

# Install NixOS
echo "Installing NixOS..."
nixos-install --no-root-passwd || { echo "Error installing NixOS"; exit 1; }

echo "NixOS installation complete. You can now reboot into your new system."
