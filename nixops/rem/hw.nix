# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # exfat support for Nintendo Switch / other SD cards
  boot.supportedFilesystems = [ "btrfs" "ext4" "exfat" ];
  virtualisation.docker.storageDriver = "btrfs";

  # Video.
  boot.earlyVconsoleSetup = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Freeness (that is, not.)
  hardware.enableRedistributableFirmware = true; # for amdgpu
  hardware.cpu.intel.updateMicrocode = true;

  fileSystems."/" = {
    device = "/dev/mapper/root"; 
    options = [ "compress=zstd" ];
  };
  boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/8a1b105c-5772-477e-8b60-49de6ccf4b86";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/725D-8B6F";
      fsType = "vfat";
    };
  
  # Backup filesystems
  fileSystems."/mnt/emergency-backup" = {
    device = "/dev/disk/by-uuid/df38ed6d-7404-4065-bd2e-aed453f9c34e";
    options = [ "errors=remount-ro" ];
    fsType = "ext4";
  };

  fileSystems."/mnt/data0" = {
    device = "/dev/mapper/data0";
    options = [ "errors=remount-ro" "noatime" "noexec" "nodev" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/6addfbee-f237-41b3-9a2b-8ced3d57f410";
      keyFile = "/mnt-root/keys/keyfile-data0.bin";
      label = "data0";
    };
  };
  deployment.keys."keyfile-data0.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../secrets/keys/keyfile-data0.bin;
  };

  fileSystems."/mnt/data1" = {
    device = "/dev/mapper/data1";
    options = [ "compress=zstd" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/dff62bd6-6e2f-4e77-b1b0-226a13aa0581";
      keyFile = "/mnt-root/keys/keyfile-data1.bin";
      label = "data1";
    };
  };
  deployment.keys."keyfile-data1.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../secrets/keys/keyfile-data1.bin;
  };

  fileSystems."/mnt/data2" = {
    device = "/dev/mapper/data2";
    options = [ "errors=remount-ro" "noatime" "noexec" "nodev" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/57e6c20c-ab5e-42b0-a984-2444a80aa516";
      keyFile = "/mnt-root/keys/keyfile-data2.bin";
      label = "data2";
    };
  };
  deployment.keys."keyfile-data2.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../secrets/keys/keyfile-data2.bin;
  };

  fileSystems."/mnt/data3" = {
    device = "/dev/mapper/data3";
    options = [ "errors=remount-ro" "noatime" "noexec" "nodev" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/c4742594-f01c-4eee-927e-1535d9f222fc";
      keyFile = "/mnt-root/keys/keyfile-data3.bin";
      label = "data3";
    };
  };
  deployment.keys."keyfile-data3.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../secrets/keys/keyfile-data3.bin;
  };

  # Seagate Expansion external hard drive
  fileSystems."/mnt/data4" = {
    device = "/dev/mapper/data4";
    options = [ "errors=remount-ro" "noatime" "noexec" "nodev" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/1351af37-7548-4787-a53f-594ad892b7e3";
      keyFile = "/mnt-root/keys/keyfile-data4.bin";
      label = "data4";
    };
  };
  deployment.keys."keyfile-data4.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../secrets/keys/keyfile-data4.bin;
  };
  # Seagate Backup Plus Hub
  fileSystems."/mnt/parity0" = {
    device = "/dev/mapper/parity0";
    options = [ "errors=remount-ro" "noatime" "noexec" "nodev" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/b9eb89d2-c5f8-4eb1-b1c0-601af8b8877c";
      keyFile = "/mnt-root/keys/keyfile-parity0.bin";
      label = "parity0";
    };
  };
  deployment.keys."keyfile-parity0.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../secrets/keys/keyfile-parity0.bin;
  };
  boot.initrd.kernelModules = [ "btrfs" ];
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/mnt/parity0" ];
  };

  fileSystems."/mnt/ssd" = {
    device = "/dev/mapper/vms";
    options = [ "errors=remount-ro" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/4b7a4578-fde4-4802-a93b-3351ec538bfc";
      keyFile = "/mnt-root/keys/keyfile-vms.bin";
      label = "vms";
    };
  };
  deployment.keys."keyfile-vms.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../secrets/keys/keyfile-vms.bin;
  };

  systemd.services.wait-for-storage = {
    enable = true;
    description = "Wait for Grand Stores mount to populate";
    path = [ pkgs.gawk pkgs.lizardfs ];
    script = ''
      set -euo pipefail

      # wait until # of lost chunks in ec_2_1 (goal #5) < 10
      # a good proxy for determining "did the server completely start up?"
      while [ "$(lizardfs-admin chunks-health localhost 9421 --availability --porcelain | head -n 6 | tail -n 1 | awk '{print $NF}')" -ge 10 ]
      do
        echo "Waiting for mount..."
        sleep 1
      done

      # wait until mount is accessible
      until ls /mnt/storage; do
        sleep 1
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    after = [ "lizardfs-master.service" ];
    before = [
      "nfs-server.service"
      "transmission.service"
      "borgbackup-repo-scintillating.service"
    ];
    wantedBy = [ "multi-user.target" ];
  };
  
  # Disk and swap
  # Allow discards on the root partition
  boot.initrd.luks.devices."root".allowDiscards = true;
  services.fstrim.enable = true;
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;
  services.journald.extraConfig = "Storage=volatile";
  boot.kernel.sysctl."vm.min_free_kbytes" = 512000;
  swapDevices = [ {
    device = "/mnt/ssd/swap";
    size = 10240;
  } {
    device = "/mnt/ssd/swap2";
    size = 10240;
  } ];
  systemd.tmpfiles.rules = [
    "w /sys/module/zswap/parameters/compressor - - - - zstd"
    "w /sys/module/zswap/parameters/zpool - - - - z3fold"
    "w /sys/module/zswap/parameters/enabled - - - - Y"
  ];

  # HACKS

  # Reset keyboard on bootup (Pok3r)
  # Otherwise keys get dropped, for some reason
  # Same with webcam - mic breaks
  systemd.services.keyboard-webcam-reset = {
    description = "Keyboard & Webcam Pro 9000 Reset";
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

      for X in /sys/bus/usb/devices/*
      do
          if [ -e "$X/idVendor" ] && [ -e "$X/idProduct" ] \
          && [ 046d = $(cat "$X/idVendor") ] && [ 0809 = $(cat "$X/idProduct") ]
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
  systemd.services.kube-container-clearer = {
    description = "Clear Broken CrashLoopBackOff services";
    path = with pkgs; [ kubectl gnugrep coreutils ];
    script = ''
      set -euo pipefail

      for pod in $(kubectl get pod | grep CrashLoopBackOff | cut -d " " -f1); do
        if kubectl describe pod "$pod" | grep "OCI runtime create failed" >/dev/null; then
          echo "Deleting broken pod state $pod"
          kubectl delete pod "$pod"
        fi
      done
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wants = [ "kubernetes.target" ];
    after = [ "kubernetes.target" ];
    startAt = "minutely";
  };
}
