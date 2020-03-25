{ config, lib, pkgs, ... }:

{
  # exfat support for Nintendo Switch / other SD cards
  boot.supportedFilesystems = [ "ext4" "exfat" "xfs" "zfs" "btrfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];

  boot.zfs = {
    forceImportRoot = false;
    forceImportAll = false;
    enableUnstable = false;
    requestEncryptionCredentials = true;
  };
  services.kubernetes.path = [ pkgs.zfs ];
  
  fileSystems."/" = {
    device = "rpool/nixos/root"; 
    fsType = "zfs";
  };
  virtualisation.docker.storageDriver = "overlay2";
  services.fstrim.enable = true;

  fileSystems."/var/lib/docker" =
    { device = "/dev/zvol/rpool/docker";
      fsType = "ext4";
      options = [ "errors=remount-ro" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6579-EA36";
      fsType = "vfat";
      options = [ "nofail" ];
    };
  
  # Backup filesystems
  fileSystems."/mnt/emergency-backup" = {
    device = "/dev/disk/by-uuid/df38ed6d-7404-4065-bd2e-aed453f9c34e";
    options = [ "errors=remount-ro" "nofail" ];
    fsType = "ext4";
  };

  fileSystems."/mnt/data0" = {
    device = "/dev/mapper/data0";
    options = [ "nofail" ];
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
    keyFile = ../../../secrets/keys/keyfile-data0.bin;
  };

  fileSystems."/mnt/data1" = {
    device = "/dev/mapper/data1";
    options = [ "nofail" ];
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
    keyFile = ../../../secrets/keys/keyfile-data1.bin;
  };

  fileSystems."/mnt/data2" = {
    device = "/dev/mapper/data2";
    options = [ "nofail" ];
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
    keyFile = ../../../secrets/keys/keyfile-data2.bin;
  };

  fileSystems."/mnt/data3" = {
    device = "/dev/mapper/data3";
    options = [ "nofail" ];
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
    keyFile = ../../../secrets/keys/keyfile-data3.bin;
  };
  
  # External WD Green 1 TB
  fileSystems."/mnt/wdgreen1tb" = {
    device = "/dev/mapper/wdgreen1tb";
    options = [ "nofail" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-uuid/9b1fa77c-20eb-4b05-a44b-a25275ff78fb";
      keyFile = "/mnt-root/keys/keyfile-wdgreen1tb.bin";
      label = "wdgreen1tb";
    };
  };
  deployment.keys."keyfile-wdgreen1tb.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../../../secrets/keys/keyfile-wdgreen1tb.bin;
  };
  # Seagate Backup Plus Hub
  fileSystems."/mnt/parity0" = {
    device = "/dev/mapper/parity0";
    options = [ "nofail" "errors=continue" ];
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
    keyFile = ../../../secrets/keys/keyfile-parity0.bin;
  };

  systemd.services.storage = {
    description = "MergerFS Storage Pool";
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    serviceConfig = {
      Restart = "always";
      Type = "forking";
      ExecStart = ''
        ${pkgs.mergerfs}/bin/mergerfs -o category.create=mfs,use_ino,allow_other,nonempty,moveonenospc=true,minfreespace=20G /mnt/data*:/mnt/wdgreen1tb /mnt/storage
      '';
    };
  };

  deployment.keys."keyfile-vms.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../../../secrets/keys/keyfile-vms.bin;
  };

  # Virtual drives
  systemd.services.gdrive-mount = {
    description = "Google Drive batchfiles99@gmail.com rclone FUSE mount";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    path = [ pkgs.fuse ];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone --config /keys/rclone.conf mount gdrive-batchfiles: /mnt/gdrive --vfs-cache-mode minimal --allow-other --uid 1000 --gid 100";
    };
  };
}
