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

  systemd.services.restic = {
    enable = enableBackups;
    description = "Restic Backup";
    path = [ pkgs.restic pkgs.rclone ];
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
      WorkingDirectory = "/mnt/storage/Kevin";
      SyslogIdentifier = "restic";
    };
    script = ''
      set -euo pipefail

      export RCLONE_CONFIG=/keys/rclone.conf
      export RESTIC_PASSWORD_FILE=/keys/restic-password.txt
      export RESTIC_REPOSITORY=rclone:gsuite-stanford:restic
      export RESTIC_CACHE_DIR=/var/cache/restic
      
      restic backup /mnt/storage/Kevin -o rclone.args="serve restic --stdio --b2-hard-delete --drive-use-trash=false -v --transfers=8"
    '';
    startAt = wave-3;
  };
  environment.systemPackages = [ pkgs.restic ];

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

  services.duplicati.enable = true;

  # Root filesystem backup
  services.znapzend = {
    enable = true;
    zetup.root = {
      dataset = "rpool/nixos/root";
      plan = 	"1h=>10min,1d=>1h,1w=>1d";
      destinations.wd.dataset = "overflow/backups/root";
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

  # Can't just include it into nix config because rclone modifies it
  # periodically
  # also that's bad for passwords
  deployment.keys."rclone.conf" = {
    permissions = "600"; # rclone must be able to modify
    destDir = "/keys";
    text = builtins.readFile ../../secrets/rclone.conf.initial;
  };
  deployment.keys."restic-password.txt" = {
    permissions = "600"; # rclone must be able to modify
    destDir = "/keys";
    text = builtins.readFile ../../secrets/restic-password.txt;
  };
}
