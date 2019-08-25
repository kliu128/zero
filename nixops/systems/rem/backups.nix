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

  # G-Suite backup
  services.borgbackup.jobs.gsuite = {
    compression = "auto,zstd";
    doInit = false;
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /keys/gsuite-backup-password.txt";
    };
    extraCreateArgs = "--stats --progress -v";
    paths = "/mnt/storage/Kevin";
    repo = "/mnt/gsuite-root/gsuite-borg";
    privateTmp = false;
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
    startAt = wave-2;
  };
  # Disable ProtectSystem=strict since it appears to break borg when running
  # under rclone fuse mount
  systemd.services.borgbackup-job-gsuite.serviceConfig.ProtectSystem = lib.mkForce false;
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
      ${proxyConfig}
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
      ${proxyConfig}
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
  services.borgbackup.jobs.gschool = {
    compression = "auto,zstd";
    doInit = true;
    encryption = {
      mode = "authenticated-blake2";
      passphrase = "";
    };
    extraCreateArgs = "--stats --progress -v";
    paths = [ "/mnt/gschool/ABRHS Communal Study" ];
    repo = "/mnt/storage/Kevin/Backups/ABRHS Communal Study";
    privateTmp = false;
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
    startAt = wave-2;
  };
  systemd.services.borgbackup-job-gschool.serviceConfig.ProtectSystem = lib.mkForce false;
  systemd.services.borgbackup-job-gschool.serviceConfig.ReadWritePaths = lib.mkForce [];

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
