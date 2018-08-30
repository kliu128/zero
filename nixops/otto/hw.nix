# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "firewire_ohci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/093180dc-abbd-46b1-af91-0c6524bbee49";
      fsType = "ext4";
    };
  fileSystems."/var/lib/lizardfs-data2" =
    { device = "/dev/disk/by-uuid/614de4ca-d912-4dbd-ae18-c5866a997757";
      fsType = "ext4";
    };

  swapDevices = [ {
    device = "/swap";
    size = 4096;
  } ];

  nix.maxJobs = lib.mkDefault 4;
}
