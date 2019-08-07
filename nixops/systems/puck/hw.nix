{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  hardware.cpu.intel.updateMicrocode = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/698a2215-72ea-4890-9ed4-b5c617585616";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/dca3a63a-97fa-45fd-8cd2-0da8b610d441";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AF0A-41EC";
      fsType = "vfat";
    };
  
  # Swap with encrypted resume
  boot.resumeDevice = "/dev/mapper/root";
  swapDevices = [ {
    device = "/swap";
    size = 8096; # size of system memory (for resuming)
  } ];
  boot.kernelParams = [ "resume_offset=34816" ]; # https://wiki.archlinux.org/index.php/Dm-crypt/Swap_encryption
  
  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
