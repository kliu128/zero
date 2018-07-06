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
  # exfat support for Nintendo Switch / other SD cards
  boot.supportedFilesystems = [ "btrfs" "ext4" "exfat" ];
  boot.earlyVconsoleSetup = true;

  # Freeness (that is, not.)
  hardware.enableRedistributableFirmware = true; # for amdgpu
  nixpkgs.config.allowUnfree = true;
  hardware.cpu.intel.updateMicrocode = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/324f901f-9370-4495-98a4-0e1e8df836f9";
      fsType = "ext4";
    };
  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/8a1b105c-5772-477e-8b60-49de6ccf4b86";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B0DD-20FA";
      fsType = "vfat";
    };
  
  # Backup filesystems
  fileSystems."/mnt/emergency-backup" = {
    device = "/dev/disk/by-uuid/df38ed6d-7404-4065-bd2e-aed453f9c34e";
    fsType = "ext4";
  };

  fileSystems."/var/lib/libvirt/images" = {
    device = "/dev/mapper/vms";
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/b8ae9582-39c5-48f6-bcba-53fcd6f0c42f";
      keyFile = "/mnt-root/etc/keys/keyfile-vms.bin";
      label = "vms";
    };
  };
  environment.etc."keys/keyfile-vms.bin" = {
    mode = "400";
    source = ../secrets/keys/keyfile-vms.bin;
  };

  fileSystems."/mnt/data0" = {
    device = "/dev/mapper/data0";
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/6addfbee-f237-41b3-9a2b-8ced3d57f410";
      keyFile = "/mnt-root/etc/keys/keyfile-data0.bin";
      label = "data0";
    };
  };
  environment.etc."keys/keyfile-data0.bin" = {
    mode = "400";
    source = ../secrets/keys/keyfile-data0.bin;
  };

  fileSystems."/mnt/data1" = {
    device = "/dev/mapper/data1";
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/dff62bd6-6e2f-4e77-b1b0-226a13aa0581";
      keyFile = "/mnt-root/etc/keys/keyfile-data1.bin";
      label = "data1";
    };
  };
  environment.etc."keys/keyfile-data1.bin" = {
    mode = "400";
    source = ../secrets/keys/keyfile-data1.bin;
  };

  fileSystems."/mnt/data2" = {
    device = "/dev/mapper/data2";
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/57e6c20c-ab5e-42b0-a984-2444a80aa516";
      keyFile = "/mnt-root/etc/keys/keyfile-data2.bin";
      label = "data2";
    };
  };
  environment.etc."keys/keyfile-data2.bin" = {
    mode = "400";
    source = ../secrets/keys/keyfile-data2.bin;
  };

  fileSystems."/mnt/data3" = {
    device = "/dev/mapper/data3";
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/c4742594-f01c-4eee-927e-1535d9f222fc";
      keyFile = "/mnt-root/etc/keys/keyfile-data3.bin";
      label = "data3";
    };
  };
  environment.etc."keys/keyfile-data3.bin" = {
    mode = "400";
    source = ../secrets/keys/keyfile-data3.bin;
  };

  # Seagate Expansion external hard drive
  fileSystems."/mnt/data4" = {
    device = "/dev/mapper/data4";
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/1351af37-7548-4787-a53f-594ad892b7e3";
      keyFile = "/mnt-root/etc/keys/keyfile-data4.bin";
      label = "data4";
    };
  };
  environment.etc."keys/keyfile-data4.bin" = {
    mode = "400";
    source = ../secrets/keys/keyfile-data4.bin;
  };
  # Seagate Backup Plus Hub
  fileSystems."/mnt/parity0" = {
    device = "/dev/mapper/parity0";
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/b9eb89d2-c5f8-4eb1-b1c0-601af8b8877c";
      keyFile = "/mnt-root/etc/keys/keyfile-parity0.bin";
      label = "parity0";
    };
  };
  environment.etc."keys/keyfile-parity0.bin" = {
    mode = "400";
    source = ../secrets/keys/keyfile-parity0.bin;
  };
  # Add UAS module to initramfs
  # Required for Seagate Backup Plus hub
  boot.initrd.kernelModules = [ "uas" ];

  systemd.services.storage = {
    enable = true;
    description = "Grand Stores Mount";
    path = [ pkgs.mergerfs ];
    restartIfChanged = false; # don't want the filesystem falling out from under processes
    script = ''
      mergerfs -o defaults,allow_other,use_ino,moveonenospc=true,fsname=storage,minfreespace=50G,noforget /mnt/data\* /mnt/storage
    '';
    wantedBy = [ "local-fs.target" ];
    serviceConfig = {
      Type = "forking";
      PrivateNetwork = true;
      # Implicitly adds dependency on basic.target otherwise, which creates
      # an ordering cycle on boot
      DefaltDependencies = false;
      # Normally would be added by DefaultDependencies=
      Conflicts = [ "shutdown.target" ];
      Before = [ "shutdown.target" ];
    };
    unitConfig.RequiresMountsFor = [ "/mnt/data0" "/mnt/data1" "/mnt/data2" "/mnt/data3" "/mnt/data4" ];
  };

  systemd.tmpfiles.rules = [
    # Auto-make mount folders for filesystems that NixOS doesn't handle directly
    "d /mnt/storage 0755 root root -"
  ];

  # Disk and swap
  # Allow discards on the root partition
  boot.initrd.luks.devices."root".allowDiscards = true;
  services.fstrim.enable = true;
  boot.cleanTmpDir = true;

  # Reset keyboard on bootup (Pok3r)
  # Otherwise keys get dropped, for some reason
  systemd.services.keyboard-reset = {
    description = "Keyboard Reset";
    script = ''
      set -x
      for X in /sys/bus/usb/devices/*
      do
          if [ -e "$X/idVendor" ] && [ -e "$X/idProduct" ] \
          && [ 04d9 = $(cat "$X/idVendor") ] && [ 0141 = $(cat "$X/idProduct") ]
          then
              echo 0 >"$X/authorized"
              sleep 1
              echo 1 >"$X/authorized"
          fi
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
}
