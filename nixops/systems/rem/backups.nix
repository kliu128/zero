{ config, lib, pkgs, ... }:

let 
  wave-1 = "*-*-* 02:30:00";
  wave-2 = "*-*-* 03:00:00";
  wave-3 = "*-*-* 04:00:00";
  enableBackups = true;
in {
  systemd.services.cloud-emergency-backup = {
    enable = enableBackups;
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

  # G-Suite backup
  systemd.services.gsuite-backup = {
    enable = enableBackups;
    description = "G-Suite Backup";
    path = [ pkgs.rclone pkgs.gnugrep ];
    serviceConfig = {
      Nice = 19;
      SyslogIdentifier = "gsuite-backup";
      IPAccounting = true;
      CPUAccounting = true;
    };
    script = ''
      set -euo pipefail

      # Backup with monthly backup dirs and revisioned suffixes in each

      dir_format="+%Y-%m"
      monthly_backup_dir="$(env TZ=Etc/UTC date "$dir_format")"
      backup_suffix="$(env TZ=Etc/UTC date +"__%Y_%m_%d_%H%M%SZ")"
      # Prune the backup dir from 6 months ago
      prune_backup_dir="$(env TZ=Etc/UTC date --date="-6 months" "$dir_format")"

      rclone --config /keys/rclone.conf \
             sync /mnt/storage/Kevin gsuite-mysmccd-crypt:/Data/current \
             --backup-dir "gsuite-mysmccd-crypt:/Data/old/$monthly_backup_dir" \
             --bwlimit 8650k --transfers 8 \
             --suffix "$backup_suffix" \
             --exclude '/Computing/Data/**' \
             --exclude '/Computing/VMs/**' \
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
  deployment.keys."gsuite-backup-password.txt" = {
    permissions = "400";
    destDir = "/keys";
    text = builtins.readFile ../../secrets/gsuite-backup-password.txt;
  };

  systemd.services.switch-sync = {
    enable = false;
    path = [ pkgs.rclone ];
    serviceConfig = {
      Nice = 19;
      SyslogIdentifier = "switch-sync";
    };
    script = ''
      set -euo pipefail

      rclone --config /keys/rclone.conf \
             sync "gsuite-mysmccd:Cleartext/hbg/" "gsuite-mysmccd-crypt:/Extended/Switch ROMs" \
             -v --transfers=4 --modify-window=1s --delete-during
      chown -R kevin:users "/mnt/storage/Kevin/Computing/ROMs/Nintendo Switch"
    '';
    startAt = wave-2;
  };
  systemd.services.aci-sync = {
    enable = enableBackups;
    path = [ pkgs.rclone ];
    serviceConfig = {
      Nice = 19;
      SyslogIdentifier = "aci-sync";
    };
    script = ''
      set -euo pipefail

      rclone --config /keys/rclone.conf \
             sync "gsuite-mysmccd:Cleartext/Air Crash Investigation/" "/mnt/storage/Kevin/Videos/TV Shows/Air Crash Investigation/" \
             -v --transfers=4 --modify-window=1s
      chown -R kevin:users "/mnt/storage/Kevin/Videos/TV Shows/Air Crash Investigation/"
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
    startAt = (if enableBackups then wave-2 else []);
  };

  # Root filesystem backup
  services.znapzend = {
    enable = false;
    zetup.root = {
      dataset = "rpool/nixos/root";
      plan = 	"1h=>10min,1d=>1h,1w=>1d";
      destinations.wd.dataset = "wd-my-book-12tb/backups/root";
    };
  };
  users.users.znapzend = {
    isSystemUser = true;
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDObwE0sKBodUOIVnjB1apf5OLD3m2i5XinoIaY7wEjfYsI/XRN+j5omgJwqM85IWEhGdS4XmqsXn0ft8/igVjLgiLLVMg9NWNtPRjKstGiwl2tzsEwSFmHEsTeHQyneIOgYhbPUJS796YWsSwAUNkfgtubpJgGRcTXe/NlSnLoH+is/eE0w3+kUjC9r4aNP5Rh0+K17RwTx2eP4arY4IzPD1uQ/ui4s4Nqw1RsVM1sT3YvCU5V+hKrahFme9dYS6UDy+yjpomyEWOZJsTb8k6AbctMVzGrA1X73xkqZ82DTXA+cUAM01gOvFzt5RrwpA2GEDIfp+o9+ARuHtFpH7CM7uKnKWrtR4JfRbPcIWTwDqh0dTa7nY1xQF6U0nsOs/ywguqeJTS2ncTp9T+uO8QGgJjdh3N31Y9swpQml1DnIH2RawDsQOalt5U+3tPseT2+kYdHNO6UOnpXFsSdtVwY5F3LwjJRlrEiCA5HtX+zPO3nqExzhDPpNJ1U6ks/KR8= kevin@rem" # karmaxer znapzend ssh key
    ];
  };

  # /boot backup
  systemd.services.boot-backup = {
    enable = enableBackups;
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
    startAt = (if enableBackups then wave-2 else []);
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
        "gdrive-batchfiles:Sci" "/mnt/storage/Kevin/Backups/Scintillating/Mirror" || true
    '';
    readWritePaths = [ "/mnt/storage/Kevin/Backups/Scintillating/Mirror" "/keys" ];
    repo = "/mnt/storage/Kevin/Backups/Scintillating/Borg";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
    startAt = (if enableBackups then wave-2 else []);
  };

  systemd.services.gsuite-mount = {
    description = "G-Suite rclone FUSE mount";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    path = [ pkgs.fuse pkgs.rclone ];
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
    };
    script = ''
      rclone --config /keys/rclone.conf mount gsuite-mysmccd-crypt: \
        /mnt/gsuite --vfs-cache-mode minimal --drive-use-trash=false \
        --allow-other --uid 1000 --gid 100
    '';
  };
  systemd.services.gsuite-unencrypted-mount = {
    description = "G-Suite rclone FUSE mount (unencrypted)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    path = [ pkgs.fuse pkgs.rclone ];
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
    };
    script = ''
      rclone --config /keys/rclone.conf \
        mount gsuite-mysmccd: /mnt/gsuite-root \
        --drive-use-trash=false \
        --vfs-cache-mode writes --vfs-cache-max-size 5G --cache-dir /mnt/storage/tmp \
        --allow-other --allow-non-empty --uid 1000 --gid 100
    '';
  };
  systemd.services.gschool-mount = {
    description = "School Google Drive Mount";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    path = [ pkgs.fuse pkgs.rclone ];
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
    };
    script = ''
      rclone --config /keys/rclone.conf \
        mount gsuite-school: /mnt/gschool \
        --drive-use-trash=false --read-only \
        --allow-other --allow-non-empty --uid 1000 --gid 100
    '';
  };
  systemd.services.dropbox-mount = {
    description = "Dropbox Mount";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    path = [ pkgs.fuse pkgs.rclone ];
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
    };
    script = ''
      rclone --config /keys/rclone.conf \
        mount dropbox: /mnt/dropbox \
        --allow-other --allow-non-empty --uid 1000 --gid 100
    '';
  };

  # Can't just include it into nix config because rclone modifies it
  # periodically
  # also that's bad for passwords
  deployment.keys."rclone.conf" = {
    permissions = "600"; # rclone must be able to modify
    destDir = "/keys";
    text = builtins.readFile ../../secrets/rclone.conf.initial;
  };
}
