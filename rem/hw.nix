# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.earlyVconsoleSetup = true;
  services.journald.extraConfig = "Storage=volatile";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/324f901f-9370-4495-98a4-0e1e8df836f9";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/8a1b105c-5772-477e-8b60-49de6ccf4b86";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B0DD-20FA";
      fsType = "vfat";
    };
  
  # Disk and swap
  # Allow discards on the root partition
  boot.initrd.luks.devices."root".allowDiscards = true;
  services.fstrim.enable = true;
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;
  swapDevices = [ {
    device = "/swap";
    size = 4096;
  } ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd*[!0-9]|sr*", ATTR{queue/scheduler}="bfq"
  '';

  nix.maxJobs = lib.mkDefault 8;
}
