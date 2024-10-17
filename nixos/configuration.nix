{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
      loader = {
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          efiInstallAsRemovable = true;
        };
        timeout = 0;
      };
      kernelPackages = pkgs.linuxPackages-rt_latest;
      consoleLogLevel = 0;
      initrd = {
        verbose = false;
        supportedFilesystems = [ "vfat" "btrfs" "erofs" ];
      };
      kernelParams = [
        "nomodeset"
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
      plymouth.enable = true;
    };
    virtualisation.vmware.guest.enable = true;

    networking.hostName = "nixcab";

    i18n.defaultLocale = "en_US.UTF-8";

    services = {
      xserver = {
        enable = true;
        xkb.layout = "us";
      };
      libinput.enable = true;
      openssh.enable = true;
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
            user = "app";
          };
        };
      };
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    sound.enable = true;
    hardware = {
      pulseaudio.enable = true;
      opengl = {
        enable = true;
        driSupport = true;
      };
    };

    users.users = {
      sys = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        packages = with pkgs; [];
      };
      app = {
        isNormalUser = true;
        extraGroups = [ "wheel" "video" "audio" ];
        packages = with pkgs; [];
      };
    };

    environment.systemPackages = with pkgs; [
      vim
      curl
      neofetch
    ];

    system.stateVersion = "24.05";
}
