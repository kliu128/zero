{ config, lib, pkgs, ... }:

let 
  wave-1 = "*-*-* 02:30:00";
  wave-2 = "*-*-* 03:00:00";
  wave-3 = "*-*-* 04:00:00";

  proxyConfig = ''
    export http_proxy="$(cat /keys/pia-proxy.txt)"
    export https_proxy=$http_proxy
    export HTTP_PROXY=$http_proxy
    export HTTPS_PROXY=$http_proxy
  '';
in {
  systemd.services.cloud-emergency-backup = {
    enable = true;
    description = "Cloud Emergency Backup";
    path = [ pkgs.rclone ];
    script = ''
      set -xeuo pipefail
      backup_suffix="$(env TZ=Etc/UTC date +"__%Y_%m_%d_%H%M%SZ")"
      dests=("gdrive-batchfiles-crypt:/Emergency Backup" "dropbox-crypt:/Emergency Backup")
      for dest in "''${dests[@]}"; do
          rclone --config /keys/rclone.conf \
                sync -vv \
                --backup-dir "$dest (old)" \
                --suffix "$backup_suffix" \
                "/mnt/storage/Kevin/Personal/Documents/Passwords" \
                "$dest/Passwords"
          rclone --config /keys/rclone.conf \
                sync -vv \
                --backup-dir "$dest (old)" \
                --suffix "$backup_suffix" \
                "/mnt/storage/Kevin/Personal/Documents/Cryptocurrency Wallets" \
                "$dest/Cryptocurrency Wallets"
      done
    '';
    serviceConfig = {
      Nice = 19;
    };
    startAt = wave-1;
  };
  systemd.services.gsuite-backup = {
    enable = true;
    description = "G-Suite Restic Backup";
    path = [ pkgs.rclone pkgs.restic pkgs.gnugrep ];
    serviceConfig = {
      Nice = 19;
      SyslogIdentifier = "gsuite-backup";
      IPAccounting = true;
      CPUAccounting = true;
      MemoryHigh = "512M";
    };
    script = ''
      set -euo pipefail

      # Backup with monthly backup dirs and revisioned suffixes in each

      ${proxyConfig}

      dir_format="+%Y-%m"
      monthly_backup_dir="$(env TZ=Etc/UTC date "$dir_format")"
      backup_suffix="$(env TZ=Etc/UTC date +"__%Y_%m_%d_%H%M%SZ")"
      # Prune the backup dir from 6 months ago
      prune_backup_dir="$(env TZ=Etc/UTC date --date="-6 months" "$dir_format")"

      rclone --config /keys/rclone.conf \
             sync /mnt/storage/Kevin gsuite-mysmccd-crypt:/Data/current \
             --backup-dir "gsuite-mysmccd-crypt:/Data/old/$monthly_backup_dir" \
             --bwlimit 8650k --transfers 32 \
             --suffix "$backup_suffix" \
             --exclude '/Computing/Data/**' \
             --exclude '/Incoming/**' \
             --exclude 'node_modules/**' \
             --exclude '.fuse_hidden*' \
             --delete-excluded -v --modify-window=1s --delete-during
      rclone --config /keys/rclone.conf \
             purge -v "gsuite-mysmccd-crypt:/Data/old/$prune_backup_dir" || true

      # export RESTIC_PASSWORD_FILE=${../../secrets/gsuite-backup-password.txt}
      # export XDG_CACHE_HOME=/var/cache/gsuite-backup
      # export RCLONE_CONFIG=/keys/rclone.conf
      # r() {
      #   restic --option=rclone.args='serve restic --stdio --drive-use-trash=false' --repo=rclone:gsuite-mysmccd:restic $@
      # }

      # r backup /mnt/storage/Kevin \
      #        --exclude '/mnt/storage/Kevin/Incoming/**/*'
      # r forget \
      #        --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 10 \
      #        --prune
    '';
    startAt = wave-3;
  };
  systemd.services.switch-sync = {
    enable = true;
    path = [ pkgs.rclone ];
    serviceConfig = {
      Nice = 19;
      SyslogIdentifier = "switch-sync";
    };
    script = ''
      set -euo pipefail

      ${proxyConfig}

      rclone --config /keys/rclone.conf \
             sync "gsuite-mysmccd:Cleartext/hbg/" "gsuite-mysmccd-crypt:/Extended/Switch ROMs" \
             -v --transfers=4 --modify-window=1s --delete-during
      chown -R kevin:users "/mnt/storage/Kevin/Computing/ROMs/Nintendo Switch"
    '';
    startAt = wave-2;
  };
  systemd.services.aci-sync = {
    enable = true;
    path = [ pkgs.rclone ];
    serviceConfig = {
      Nice = 19;
      SyslogIdentifier = "aci-sync";
    };
    script = ''
      set -euo pipefail

      ${proxyConfig}

      rclone --config /keys/rclone.conf \
             sync "gsuite-mysmccd:Cleartext/Air Crash Investigation/" "/mnt/storage/Kevin/Videos/TV Shows/Air Crash Investigation/" \
             -v --transfers=4 --modify-window=1s
      chown -R kevin:users "/mnt/storage/Kevin/Videos/TV Shows/Air Crash Investigation/"
    '';
    startAt = wave-2;
  };
  systemd.services.gschool-sync = {
    enable = true;
    description = "School Drive Synchronization";
    path = [ pkgs.rclone ];
    serviceConfig = {
      Nice = 19;
    };
    script = ''
      set -xeuo pipefail
      # Skip gdocs because often I may convert a document to Google Doc for peer editing
      rclone --config /keys/rclone.conf copy /mnt/storage/Kevin/Personal/Documents/School gsuite-school:Sync/ --drive-skip-gdocs
    '';
  };
  systemd.timers.gschool-sync = {
    enable = true;
    timerConfig.OnActiveSec = 3600;
    wantedBy = [ "timers.target" ];
  };

  systemd.services.photo-sync = {
    description = "Sync 7+ Day Old Photos from Phone to PC";
    path = [ pkgs.rsync ];
    serviceConfig = {
      User = "kevin";
      Group = "users";
    };
    script = ''
      set -euo pipefail
      cd "/mnt/storage/Kevin/Personal/Media/SYNCED OnePlus 6t Current Photos"
      find . -type f -mtime +7 -print0 | 
        rsync -0avP --remove-source-files --files-from=- ./ "../UNSORTED OnePlus 6t Camera Roll"
    '';
    startAt = wave-2;
  };

  # BorgBackup jobs
  services.borgbackup.jobs.emergency-backup = {
    repo = "/mnt/emergency-backup/emergency-borg";
    doInit = false;
    compression = "lzma";
    encryption = {
      mode = "repokey";
      passphrase = builtins.readFile ../../secrets/emergency-borg-password.txt;
    };
    paths = [
      "/mnt/storage/Kevin/Personal/Documents"
      "/mnt/storage/Kevin/Personal/Code"
      "/keys"
      "/home/kevin/Projects/zero"
    ];
    extraCreateArgs = "--stats --progress -v";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
    startAt = wave-2;
  };

  # Root filesystem backup
  services.borgbackup.jobs.root = {
    doInit = true;
    compression = "auto,zstd";
    encryption = {
      mode = "repokey";
      passphrase = builtins.readFile ../../secrets/storage-borg-password.txt;
    };
    exclude = [
      "sh:/home/*/.cache/*"
      "sh:/var/lib/docker/*"
      "sh:/var/lib/kubernetes/*"
      "sh:/var/log/*"
      "sh:/var/tmp/*"
      "sh:/var/cache/*"
    ];
    extraCreateArgs = "--one-file-system --stats";
    paths = [ "/" ];
    repo = "/mnt/storage/Kevin/Backups/Systems/storage-borg";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 3;
    };
    startAt = wave-1;
  };
  systemd.services.borgbackup-job-root.serviceConfig.SuccessExitStatus = [ 1 ];
  environment.etc."keys/backups.borg-key" = {
    mode = "400";
    text = builtins.readFile ../../secrets/keys/backups.borg-key;
  };

  # Backup hosting for Scintillating
  services.borgbackup.repos.scintillating = {
    # Placeholder
    authorizedKeys = [ (import ../../ssh-keys.nix).root-karmaxer ];
    path = "/mnt/storage/Kevin/Backups/Systems/scintillating-borg";
    quota = "250G";
  };

  # /boot backup
  systemd.services.boot-backup = {
    enable = true;
    description = "/boot Backup";
    path = [ pkgs.rsync ];
    script = ''
      rsync -avP /boot /mnt/emergency-backup/boot
    '';
    startAt = wave-2;
  };
  
  # Mirror services
  systemd.services.gas-leak-mirror = {
    description = "Google Drive Gas Leak Data Mirroring";
    path = [ pkgs.rclone ];
    script = ''
      rclone --config /keys/rclone.conf sync --verbose --drive-formats ods,odt,odp,svg "gsuite-school:Acton Gas Leak Area Data" "/mnt/storage/Kevin/Backups/Acton Gas Leak Data Mirror"
      chown -R kevin:users "/mnt/storage/Kevin/Backups/Acton Gas Leak Data Mirror"
    '';
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      SyslogIdentifier = "gas-leak-mirror";
    };
    unitConfig = {
      RequiresMountsFor = [ "/mnt/storage" ];
    };
    startAt = wave-2;
  };
  services.borgbackup.jobs.scintillating-backup = {
    paths = [ "/mnt/storage/Kevin/Backups/Scintillating/Mirror" ];
    encryption.mode = "none";
    preHook = ''
      # Drive alternate export: otherwise it fails to download files >~5 MB
      # see https://github.com/ncw/rclone/issues/2243
      ${pkgs.rclone}/bin/rclone \
        --config /keys/rclone.conf \
        sync \
        --verbose --drive-formats ods,odt,odp,svg \
        --drive-alternate-export \
        "gdrive-batchfiles:Sci" "/mnt/storage/Kevin/Backups/Scintillating/Mirror"
    '';
    readWritePaths = [ "/mnt/storage/Kevin/Backups/Scintillating/Mirror" "/keys" ];
    repo = "/mnt/storage/Kevin/Backups/Scintillating/Borg";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
    startAt = wave-2;
  };

  # Can't just include it into nix config because rclone modifies it
  # periodically
  # also that's bad for passwords
  deployment.keys."rclone.conf" = {
    permissions = "600"; # rclone must be able to modify
    destDir = "/keys";
    text = builtins.readFile ../../secrets/rclone.conf.initial;
  };
  deployment.keys."pia-proxy.txt" = {
    permissions = "400";
    destDir = "/keys";
    text = builtins.readFile ../../secrets/pia-proxy.txt;
  };

  services.snapper = {
    configs."storage" = {
      fstype = "btrfs";
      subvolume = "/mnt/storage";
    };
  };
}