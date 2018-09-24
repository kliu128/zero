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
    description = "G-Suite Restic Backup";
    path = [ pkgs.rclone pkgs.restic ];
    serviceConfig = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
    script = ''
      set -xeuo pipefail

      XDG_CACHE_HOME=/var/cache/gsuite-backup RESTIC_PASSWORD_FILE=${../secrets/gsuite-backup-password.txt} RCLONE_CONFIG=/etc/rclone.conf restic -o rclone.connections=16 -o rclone.args='serve restic --stdio -v --drive-use-trash=false' -r rclone:gsuite-mysmccd:gsuite-restic backup  --exclude '/mnt/storage/Kevin/Incoming/**/*' /mnt/storage/Kevin
    '';
    startAt = "*-*-* 03:00:00";
  };
  systemd.services.gschool-sync = {
    enable = true;
    description = "School Drive Synchronization";
    path = [ pkgs.rclone ];
    serviceConfig = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
    script = ''
      set -xeuo pipefail
      # Skip gdocs because often I may convert a document to Google Doc for peer editing
      rclone --config /etc/rclone.conf sync /mnt/storage/Kevin/Personal/Documents/School gsuite-school:Sync/ --drive-skip-gdocs
    '';
  };
  systemd.timers.gschool-sync = {
    enable = true;
    timerConfig.OnUnitActiveSec = 3600;
    wantedBy = [ "timers.target" ];
  };
  systemd.tmpfiles.rules = [
    "d /var/cache/gsuite-backup 0400 root root -"
  ];
  systemd.services.lizardfs-snapshot = {
    enable = true;
    description = "LizardFS daily snapshot";
    path = [ pkgs.lizardfs ];
    script = ''
      set -xeuo pipefail
      lizardfs makesnapshot -l /mnt/storage/Kevin "/mnt/storage/snapshots/$(date "+%Y-%m-%d")"
      num_snapshots=$(ls /mnt/storage/snapshots | wc -l)
      if [ "$num_snapshots" -gt 1 ]; then
        oldest_snapshot=$(ls -t /mnt/storage/snapshots | tail -n 1)
        lizardfs rremove -l "/mnt/storage/snapshots/$oldest_snapshot"
      fi
    '';
    startAt = "daily";
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

  # Root filesystem backup
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
      "sh:/var/lib/kubernetes/*"
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
  systemd.services.borgbackup-job-root-backup.serviceConfig.SuccessExitStatus = [ 1 ];

  # Backup hosting for Scintillating
  services.borgbackup.repos.scintillating = {
    # Placeholder
    authorizedKeys = [ (import ../ssh-keys.nix).root-karmaxer ];
    path = "/mnt/storage/Kevin/Backups/Systems/scintillating-borg";
    quota = "150G";
  };

  # /boot backup
  systemd.services.boot-backup = {
    enable = true;
    description = "/boot Backup";
    path = [ pkgs.rsync ];
    script = ''
      rsync -avP /boot /mnt/storage/Kevin/Backups/Systems/boot
    '';
    unitConfig = {
      RequiresMountsFor = [ "/mnt/storage" ];
    };
    startAt = "daily";
  };
  
  # Mirror services
  systemd.services.gas-leak-mirror = {
    description = "Google Drive Gas Leak Data Mirroring";
    path = [ pkgs.rclone ];
    script = ''
      rclone --config /etc/rclone.conf sync --verbose --drive-formats ods,odt,odp,svg "gsuite-school:Acton Gas Leak Area Data" "/mnt/storage/Kevin/Backups/Acton Gas Leak Data Mirror"
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
    description = "Scintillating Drive Mirroring";
    path = [ pkgs.rclone ];
    script = ''
      # Drive alternate export: otherwise it fails to download files >~5 MB
      # see https://github.com/ncw/rclone/issues/2243
      rclone \
        --config /etc/rclone.conf \
        sync \
        --verbose --drive-formats ods,odt,odp,svg \
        --drive-alternate-export \
        "gdrive-batchfiles:Scintillating" "/mnt/storage/Kevin/Backups/Scintillating Drive"
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
