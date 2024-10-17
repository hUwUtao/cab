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

  boot.initrd = {
    luks.devices."cryptroot" = {
      device = "/dev/disk/by-label/CABSECROOT";
      keyFile = "/luks.key";
      preLVM = true;
    };
    secrets = {
      "/luks.key" = "/etc/nixos/luks.key";
    };
  };

  fileSystems = {
    "/" = {
        device = "/dev/mapper/cryptroot";
        fsType = "btrfs";
        options = [ "subvol=@" "noatime" "compress=zstd" "space_cache=v2" ];
    };

    "/boot" = {
        device = "/dev/disk/by-label/CABEFI";
        fsType = "vfat";
        options = [ "noatime" ];
    };

    "/nix" = {
        device = "/dev/mapper/cryptroot";
        fsType = "btrfs";
        options = [ "subvol=@nix" "noatime" "compress=zstd" "space_cache=v2" ];
    };

    "/etc/nixos" = {
      device = "/dev/disk/by-label/CABDEPLOYFS";
      fsType = "vfat";
      options = [ "defaults" "nofail" "x-systemd.automount" "x-systemd.device-timeout=5s" "noauto" "noatime" ];
      neededForBoot = true;
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/CABSWAP"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
