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

  # BorgBackup jobs
  services.borgbackup.jobs.emergency-backup = {
    repo = "/mnt/emergency-backup/emergency-borg";
    doInit = false;
    compression = "lzma";
    encryption = {
      mode = "repokey";
      passphrase = builtins.readFile ../secrets/emergency-borg-password.txt;
    };
    paths = [
      "/mnt/storage/Kevin/Personal/Documents"
      "/mnt/storage/Kevin/Personal/Code"
      "/etc/keys"
    ];
    extraCreateArgs = "--stats --progress -v";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
  };
  services.borgbackup.jobs.root-backup = {
    doInit = false; # Already exists
    compression = "auto,lzma";
    encryption = {
      mode = "repokey";
      passphrase = builtins.readFile ../secrets/storage-borg-password.txt;
    };
    exclude = [
      "sh:/home/*/.cache/*"
      "sh:/var/lib/docker/*"
      "sh:/var/log/*"
    ];
    extraCreateArgs = "--one-file-system --stats --progress -v";
    paths = "/";
    repo = "/mnt/storage/Kevin/Backups/Systems/storage-borg";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
  };
  environment.etc."keys/backups.borg-key" = {
    mode = "400";
    text = builtins.readFile ../secrets/keys/backups.borg-key;
  };

  # Backup hosting for Scintillating
  services.borgbackup.repos.scintillating = {
    # Placeholder
    authorizedKeys = [ (import ../ssh-keys.nix).kevin-rem ];
    path = "/mnt/storage/Kevin/Backups/Systems/scintillating-borg";
    quota = "150G";
  };

  # SnapRAID
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
      autosave 1000
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
  
  # Mirror services
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
  systemd.services.scintillating-mirror = {
    description = "Google Drive Gas Leak Data Mirroring";
    path = [ pkgs.rclone ];
    script = ''
      rclone --config /etc/rclone.conf sync --verbose --drive-formats ods,odt,odp,svg "gdrive-batchfiles:Scintillating" "/mnt/storage/Kevin/Backups/Scintillating Drive"
      chown -R kevin:users "/mnt/storage/Kevin/Backups/Scintillating Drive"
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
