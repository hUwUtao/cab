{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "ehci_pci" "ahci" "sd_mod" "sr_mod" "usb_storage" "btrfs" "vfat" "erofs" ];
      kernelModules = [ "erofs" "vfat" "usb_storage" ];
    };
    kernelModules = [ "btrfs" "erofs" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/CABROOT";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/CABEFI";
      fsType = "vfat";
    };

    "/nix" = {
      device = "/dev/disk/by-label/CABROOT";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    };

    "/etc/nixos" = {
      device = "/dev/disk/by-label/CABDEPLOYFS";
      fsType = "vfat";
      options = [ "defaults" "nofail" "x-systemd.automount" ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/CABSWAP"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens33.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
