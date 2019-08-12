# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b8b682fc-bc1b-4e19-9040-52100d0801be";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/eee793e6-8639-445b-b044-b5c4e69dd87f";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F18D-71C5";
      fsType = "vfat";
    };

  swapDevices = [
    {
      device = "/swap";
      size = 16384;
    }
  ];
  boot.resumeDevice = "/dev/mapper/root";
  boot.kernelParams = [ "resume_offset=8800256" ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # High-DPI console
  i18n.consoleFont = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  boot.earlyVconsoleSetup = true;

  # Configure GRUB with hidpi support
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    useOSProber = true;
    # Use an OpenType font (auto-converted to grub pf2) so that we can set a
    # custom font size
    font = "${pkgs.fira-code}/share/fonts/opentype/FiraCode-Regular.otf";
    # Double the default font of 16 for 200% scaling
    fontSize = 32;
    device = "nodev"; # Disable MBR installation
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Disable the gpu.
  hardware.nvidiaOptimus.disable = true;

  # Windows dual-boot compatibility - time compat
  time.hardwareClockInLocalTime = true;

  services.xserver.videoDrivers = [ "intel" ];
}