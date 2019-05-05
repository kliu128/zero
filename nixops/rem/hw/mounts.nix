{ config, lib, pkgs, ... }:

{
  # exfat support for Nintendo Switch / other SD cards
  boot.supportedFilesystems = [ "btrfs" "ext4" "exfat" "zfs" ];
  boot.initrd.supportedFilesystems = [ "zfs" ];

  boot.zfs = {
    forceImportRoot = false;
    forceImportAll = false;
    enableUnstable = true;
    requestEncryptionCredentials = true;
  };
  services.kubernetes.path = [ pkgs.zfsUnstable ];
  boot.kernelParams = [ "zfs.zvol_request_sync=1" ];

  systemd.services.zfs-renice = {
    enable = true;
    description = "Renice ZFS IO threads";
    path = [ pkgs.procps pkgs.utillinux ];
    script = ''
      while true; do
        renice -n 5 -p $(pgrep z_wr_iss) || true
        renice -n 5 -p $(pgrep z_rd_int) || true
        sleep 1
      done
    '';
    wantedBy = [ "multi-user.target" ];
  };
  
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
    options = [ "errors=remount-ro" "noatime" "lazytime" "noexec" "nodev" ];
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
    keyFile = ../../secrets/keys/keyfile-data0.bin;
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
    keyFile = ../../secrets/keys/keyfile-data1.bin;
  };

  fileSystems."/mnt/data2" = {
    device = "/dev/mapper/data2";
    options = [ "errors=remount-ro" "noatime" "lazytime" "noexec" "nodev" ];
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
    keyFile = ../../secrets/keys/keyfile-data2.bin;
  };

  fileSystems."/mnt/data3" = {
    device = "/dev/mapper/data3";
    options = [ "errors=remount-ro" "noatime" "lazytime" "noexec" "nodev" ];
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
    keyFile = ../../secrets/keys/keyfile-data3.bin;
  };

  # Seagate Expansion external hard drive
  fileSystems."/mnt/data4" = {
    device = "data4";
    fsType = "zfs";
    options = [ "noatime" "lazytime" "noexec" "nodev" ];
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
    keyFile = ../../secrets/keys/keyfile-data4.bin;
  };
  # Seagate Backup Plus Hub
  fileSystems."/mnt/parity0" = {
    device = "parity0";
    fsType = "zfs";
    options = [ "noatime" "lazytime" "noexec" "nodev" ];
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
    keyFile = ../../secrets/keys/keyfile-parity0.bin;
  };

  deployment.keys."keyfile-vms.bin" = {
    permissions = "400";
    destDir = "/keys";
    keyFile = ../../secrets/keys/keyfile-vms.bin;
  };

  systemd.services.wait-for-storage = {
    enable = true;
    description = "Wait for Grand Stores mount to populate";
    path = [ pkgs.gawk pkgs.lizardfs pkgs.netcat-gnu ];
    script = ''
      # Wait for total number of chunks to be < 10
      while ! nc -z 10.99.0.1 9421; do   
        sleep 0.1 # wait for 1/10 of the second before check again
      done

      while [ "$(lizardfs-admin chunks-health 10.99.0.1 9421 --availability --porcelain | awk '{s+=$5} END {print s}')" -ge 10 ]
      do
        echo "Waiting for mount..."
        sleep 1
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
  systemd.services.storage = {
    after = [ "wait-for-storage.service" ];
    wants = [ "wait-for-storage.service" ];
    before = [
      "samba-smbd.service"
      "nfs-server.service"
      "transmission.service"
      "borgbackup-repo-scintillating.service"
      "syncthing.service"
      "docker.service"
    ];
  };

  systemd.services.gdrive-mount = {
    description = "batchfiles99@gmail.com rclone FUSE mount";
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
  systemd.tmpfiles.rules = [
    "d /mnt/gdrive 0755 root root -"
  ];
}
