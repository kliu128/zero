{ config, lib, pkgs, ... }:

{
  systemd.services.crypto-wallet-backup = {
    enable = true;
    description = "Cryptowallet Backup";
    path = [ pkgs.rclone ];
    script = ''
      dests=("gdrive-batchfiles-crypt:/Cryptocurrency Wallets" "dropbox-crypt:/Cryptocurrency Wallets")
      for dest in "''${dests[@]}"; do
          rclone --config /etc/rclone.conf \
                sync -vv \
                '/mnt/storage/Kevin/Personal/Documents/Cryptocurrency Wallets' \
                "$dest"
      done
    '';
    serviceConfig = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
    startAt = "daily";
  };
  systemd.services.gsuite-backup = {
    enable = true;
    description = "Gsuite backup";
    path = [ pkgs.rclone ];
    serviceConfig = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
    script = ''
      set -xeuo pipefail

      # Backup with monthly backup dirs and revisioned suffixes in each

      dir_format="+%Y-%m"
      monthly_backup_dir="$(env TZ=Etc/UTC date "$dir_format")"
      backup_suffix="$(env TZ=Etc/UTC date +"__%Y_%m_%d_%H%M%SZ")"
      # Prune the backup dir from 6 months ago
      prune_backup_dir="$(env TZ=Etc/UTC date --date="-6 months" "$dir_format")"

      rclone --config /etc/rclone.conf \
            sync /mnt/storage/Kevin gsuite-mysmccd-crypt:/Data/current \
            --backup-dir "gsuite-mysmccd-crypt:/Data/old/$monthly_backup_dir" \
            --bwlimit 8650k --transfers 32 --checkers 32 \
            --suffix "$backup_suffix" \
            --exclude '/Computing/Data/**' \
            --exclude '/Incoming/**' \
            --exclude 'node_modules/**' \
            --exclude '.fuse_hidden*' \
            --delete-excluded
      rclone --config /etc/rclone.conf \
            purge -v "gsuite-mysmccd-crypt:/Data/old/$prune_backup_dir" || true
    '';
    startAt = "*-*-* 03:00:00";
  };
  systemd.services.matrix-recorder = {
    description = "Matrix Recorder";
    path = [ pkgs.nodejs pkgs.curl ];
    script = ''
      set -xeuo pipefail

      while [[ "$(curl -s -o /dev/null -w '''%{http_code}''' https://potatofrom.space)" != "200" ]]; do
        sleep 5
      done

      cd '/mnt/storage/Kevin/Backups/Online Services/matrix-recorder'
      node matrix-recorder.js ./logs &
      sleep 1200 # 20 min should be sufficient to get the day's messages
      kill %1
    '';
    serviceConfig = {
      User = "kevin";
    };
    wants = [ "storage.service" "docker.service" "network-online.target" ];
    after = [ "storage.service" "docker.service" "network-online.target" ];
    startAt = "daily";
  };
  systemd.services.emergency-backup = {
    description = "Borg Backup to Emergency Backup USB";
    restartIfChanged = false;
    path = [ pkgs.borgbackup ];
    script = ''
      set -xeuo pipefail
      repo="/mnt/emergency-backup/borg"
      export BORG_PASSPHRASE='***REMOVED***'
      borg create "$repo::{hostname}-documents-{utcnow}" /mnt/storage/Kevin/Personal/Documents \
          --verbose --progress --stats \
          --compression lzma
      borg create "$repo::{hostname}-programming-{utcnow}" /mnt/storage/Kevin/Personal/Code \
          --verbose --progress --stats \
          --compression lzma
      borg create "$repo::{hostname}-keys-{utcnow}" /etc/keys \
          --verbose --progress --stats \
          --compression lzma
      backups=("{hostname}-documents" "{hostname}-programming" "{hostname}-keys")
      for backup in "''${backups[@]}"; do
          borg prune -v --list --prefix "$backup" \
              --keep-daily=7 --keep-weekly=4 --keep-monthly=-1 \
              "$repo"
      done
    '';
    unitConfig = {
      RequiresMountsFor = [ "/mnt/emergency-backup" ];
    };
    serviceConfig = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
    wants = [ "storage.service" ];
    after = [ "storage.service" ];
    startAt = "daily";
  };
  systemd.services.root-backup = {
    description = "Borg Backup of / to /mnt/storage";
    restartIfChanged = false;
    path = [ pkgs.borgbackup ];
    script = ''
      set -xeuo pipefail
      export BORG_PASSPHRASE='***REMOVED***'
      borg create -v --progress --stats \
          --one-file-system \
          --exclude 'sh:/home/*/.cache/*' \
          --exclude 'sh:/var/lib/docker/*' \
          --exclude 'sh:/var/log/*' \
          --compression auto,lzma \
          /mnt/storage/Kevin/Backups/System\ Images/storage-borg::{hostname}-root-{now} / || true
      borg prune -v --list --keep-daily=7 --keep-weekly=4 --keep-monthly=-1 /mnt/storage/Kevin/Backups/System\ Images/storage-borg
    '';
    wants = [ "storage.service" ];
    after = [ "storage.service" ];
    serviceConfig = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
    unitConfig.RequiresMountsFor = [ "/" ];
    startAt = "daily";
  };
  environment.etc."keys/backups.borg-key" = {
    mode = "400";
    text = builtins.readFile ../secrets/keys/backups.borg-key;
  };
  systemd.services.snapraid = {
    description = "SnapRAID Synchronization and Maintenance";
    path = [ pkgs.snapraid ];
    script = ''
      set -xeuo pipefail
      snapraid sync && snapraid scrub && snapraid status
    '';
    serviceConfig = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
    startAt = "*-*-* 03:00:00";
  };
  environment.etc."snapraid.conf" = {
    text = ''
      block_size 256
      autosave 5
      content /mnt/data0/snapraid.content
      content /mnt/data1/snapraid.content
      content /mnt/data2/snapraid.content
      content /mnt/data3/snapraid.content
      content /mnt/data4/snapraid.content
      disk data0 /mnt/data0
      disk data1 /mnt/data1
      disk data2 /mnt/data2
      disk data3 /mnt/data3
      disk data4 /mnt/data4
      parity /mnt/parity0/snapraid.parity

      exclude *.bak
      exclude *.unrecoverable
      exclude /tmp/
      exclude lost+found/
      exclude .content
      exclude aquota.group
      exclude aquota.user
      exclude snapraid.conf*
      exclude /Kevin/Computing/Software/Data/
      exclude /Kevin/Incoming/
    '';
  };
  
  systemd.services.gas-leak-mirror = {
    description = "Google Drive Gas Leak Data Mirroring";
    path = [ pkgs.rclone ];
    script = ''
      rclone --config /etc/rclone.conf sync --verbose --drive-formats ods,odt,odp,svg "gsuite-school:10th Grade/Acton Gas Leak Area Data" "/mnt/storage/Kevin/Backups/Acton Gas Leak Data Mirror"
      chown -R kevin:users "/mnt/storage/Kevin/Backups/Acton Gas Leak Data Mirror"
    '';
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
    unitConfig = {
      RequiresMountsFor = [ "/mnt/storage" ];
    };
    startAt = "daily";
  };

  # Can't just include it into nix config because rclone modifies it
  # periodically
  # TODO: Stop storing passwords in Nix store!
  environment.etc."rclone.conf" = {
    mode = "0666"; # do not symlink, rclone must be able to modify
    text = builtins.readFile ../secrets/rclone.conf.initial;
  };
}