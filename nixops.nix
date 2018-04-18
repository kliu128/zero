# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  rem =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "192.168.1.5";

      imports = [
        ./rem/desktop.nix
        # Include the results of the hardware scan.
        ./rem/hw.nix
        ./rem/nfs.nix
        ./rem/nix.nix
        ./rem/vfio.nix
        ./rem/zsh.nix
        ./common/kubernetes.nix
      ];

      boot.kernelPackages = pkgs.linuxPackages_testing_bcachefs;
      boot.supportedFilesystems = [ "bcachefs" "btrfs" "ext4" ];

      services.earlyoom = {
        enable = true;
        freeMemThreshold = 3; # ~500M / 20G
      };
      zramSwap = {
        enable = true;
        numDevices = 8;
      };

      # Freeness (that is, not.)
      hardware.enableRedistributableFirmware = true; # for amdgpu
      nixpkgs.config.allowUnfree = true;
      hardware.cpu.intel.updateMicrocode = true;

      networking.hostName = "rem"; # Define your hostname
      networking.domain = "potatofrom.space";
      networking.usePredictableInterfaceNames = false;

      networking.interfaces.usb0.ipv4.addresses = [ { address = "192.168.15.201"; prefixLength = 24; } ];
      systemd.services.kindle-status = {
        enable = true;
        path = [ pkgs.telnet ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
        { sleep 1; echo "/mnt/us/extensions/kterm/bin/kterm -c 1 -k 0 -s 6 -e 'ssh kindle@192.168.15.201 -p 843 -t -- tail -f | htop --delay=100'"; sleep infinity; } | telnet 192.168.15.244
        '';
        serviceConfig.DynamicUser = true;
      };
      # Set your time zone.
      time.timeZone = "America/New_York";
      services.timesyncd.enable = false;
      services.chrony.enable = true;

      

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.bash.enableCompletion = true;
      # programs.mtr.enable = true;
      # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      services.openssh = {
        enable = true;
        passwordAuthentication = false;
        ports = [ 843 ];
        forwardX11 = true;
      };
      programs.mosh.enable = true;
      services.fail2ban = {
        enable = true;
        jails.ssh-iptables = "enabled = true";
      };
      networking.firewall.enable = true;
      networking.firewall.allowPing = false;
      networking.firewall.logRefusedConnections = false;
      # Samba
      networking.firewall.allowedTCPPorts = [
        # Samba
        139 445
        # SSH
        843
        # Docker
        2376 2377 7946
        # Syncthing
        22000
        # Steam
        27036 27037
        # Kubernetes - kubelet, etcd, apiserver
        10250 2379 2380 6443 ];
      networking.firewall.allowedUDPPorts = [
        # Samba
        137 138 
        # Docker
        4789 7946
        # Steam
        21027 27031 27036 ];



      # Network stats
      services.vnstat.enable = true;
      # Uptime tracking
      services.uptimed.enable = true;

      # Samba
      services.samba.enable = true;
      services.samba.syncPasswordsByPam = true;
      services.samba.nsswins = true;
      services.samba.shares = {
        storage = {
          browseable = "yes";
          comment = "Public samba share.";
          "guest ok" = "yes";
          path = "/mnt/storage";
          "read only" = false;
          "acl allow execute always" = true; # Allow executing EXEs
        };
      };

      programs.gnupg.agent.enable = true;
      security.pam.services.login.enableKwallet = true;

      programs.adb.enable = true;
      # Scanner
      hardware.sane.enable = true;

      # Enable automatic discovery of the printer (from other linux systems with avahi running)
      services.avahi.enable = true;
      services.avahi.publish.enable = true;
      services.avahi.publish.userServices = true;
      services.avahi.nssmdns = true; # allow .local resolving

      # Enable the X11 windowing system.
      services.xserver.enable = true;

      # Enable touchpad support.
      services.xserver.libinput.enable = true;

      # Video.
      services.xserver.videoDrivers = [ "amdgpu" ];
      hardware.opengl.driSupport32Bit = true; # for steam and wine

      services.xserver.displayManager.sddm.enable = true;

      services.xserver.windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [ blueman compton conky dunst i3lock nitrogen redshift rofi system-config-printer scrot xautolock xcape xorg.xmodmap termite udiskie ];
      };

      # Keyboard layout
      services.xserver.layout = "us";
      services.xserver.xkbVariant = "altgr-intl";
      services.xserver.xkbOptions = "ctrl:nocaps";

      services.emacs.enable = true;
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.root.hashedPassword = "***REMOVED***";
      users.extraUsers.kevin = {
        description = "Kevin Liu";
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "wheel" "docker" "input" "libvirtd" "sway" "wireshark" ];
        hashedPassword = "***REMOVED***";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvRm/l9jaQ3fN5ZQvmZCfhKGHgtizonT9BRSKFbbgro kevin@emilia"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGBlgyWrDlIJ5RWigaWGOmjVWBpPqqJ/cL58yJblfm33 kevin@xt1575"
        ];
      };
      users.extraUsers.kindle = {
        shell = pkgs.bash;
        description = "Kindle Status User";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuhNYOw//qjZTsQT99TavXaLAJLHmaDXV4YZowNWSMS root@kindle"
        ];
      };
      # Disable adding/removing users on the fly
      users.mutableUsers = false;
      security.sudo.enable = true;
      security.sudo.wheelNeedsPassword = false;
      
      # This value determines the NixOS release with which your system is to be
      # compatible, in order to avoid breaking some software such as database
      # servers. You should change this only after NixOS release notes say you
      # should.
      system.stateVersion = "unstable"; # Did you read the comment?

      services.syncthing = {
        enable = true;
        user = "kevin";
        dataDir = "/home/kevin/.config/syncthing";
      };
      services.flatpak.enable = true;

      fileSystems."/var/lib/libvirt/images" = {
        device = "/dev/mapper/vms";
        encrypted = {
          enable = true;
          blkDev = "/dev/disk/by-uuid/b8ae9582-39c5-48f6-bcba-53fcd6f0c42f";
          keyFile = "/mnt-root/etc/nixos/keys/keyfile-vms.bin";
          label = "vms";
        };
      };
      fileSystems."/mnt/data0" = {
        device = "/dev/mapper/data0";
        encrypted = {
          enable = true;
          blkDev = "/dev/disk/by-uuid/6addfbee-f237-41b3-9a2b-8ced3d57f410";
          keyFile = "/mnt-root/etc/nixos/keys/keyfile-data0.bin";
          label = "data0";
        };
      };
      fileSystems."/mnt/data1" = {
        device = "/dev/mapper/data1";
        encrypted = {
          enable = true;
          blkDev = "/dev/disk/by-uuid/dff62bd6-6e2f-4e77-b1b0-226a13aa0581";
          keyFile = "/mnt-root/etc/nixos/keys/keyfile-data1.bin";
          label = "data1";
        };
      };
      fileSystems."/mnt/data2" = {
        device = "/dev/mapper/data2";
        encrypted = {
          enable = true;
          blkDev = "/dev/disk/by-uuid/57e6c20c-ab5e-42b0-a984-2444a80aa516";
          keyFile = "/mnt-root/etc/nixos/keys/keyfile-data2.bin";
          label = "data2";
        };
      };
      fileSystems."/mnt/data3" = {
        device = "/dev/mapper/data3";
        encrypted = {
          enable = true;
          blkDev = "/dev/disk/by-uuid/c4742594-f01c-4eee-927e-1535d9f222fc";
          keyFile = "/mnt-root/etc/nixos/keys/keyfile-data3.bin";
          label = "data3";
        };
      };
      # Seagate Expansion external hard drive
      fileSystems."/mnt/data4" = {
        device = "/dev/mapper/data4";
        encrypted = {
          enable = true;
          blkDev = "/dev/disk/by-uuid/1351af37-7548-4787-a53f-594ad892b7e3";
          keyFile = "/mnt-root/etc/nixos/keys/keyfile-data4.bin";
          label = "data4";
        };
      };
      # Seagate Backup Plus Hub
      fileSystems."/mnt/parity0" = {
        device = "/dev/mapper/parity0";
        encrypted = {
          enable = true;
          blkDev = "/dev/disk/by-uuid/b9eb89d2-c5f8-4eb1-b1c0-601af8b8877c";
          keyFile = "/mnt-root/etc/nixos/keys/keyfile-parity0.bin";
          label = "parity0";
        };
      };
      systemd.services.storage = {
        enable = true;
        description = "Grand Stores Mount";
        path = [ pkgs.mergerfs ];
        restartIfChanged = false; # don't want the filesystem falling out from under processes
        script = ''
          mergerfs -o defaults,allow_other,use_ino,moveonenospc=true,fsname=storage,minfreespace=50G,category.create=rand,noforget /mnt/data\* /mnt/storage
        '';
        wantedBy = [ "local-fs.target" ];
        serviceConfig = {
          Type = "forking";
          PrivateNetwork = true;
        };
        unitConfig.RequiresMountsFor = [ "/mnt/data0" "/mnt/data1" "/mnt/data2" "/mnt/data3" "/mnt/data4" ];
      };

      # Backup filesystems
      fileSystems."/mnt/emergency-backup" = {
        device = "/dev/disk/by-uuid/417a766c-06e9-42ac-a6d1-4191614661ba";
        fsType = "bcachefs";
      };
      systemd.tmpfiles.rules = [
        # Auto-make filesystems that nixos doesn't make
        "d /mnt/storage 0755 root root -"
      ];
      systemd.services.crypto-wallet-backup = {
        enable = true;
        description = "Cryptowallet Backup";
        path = [ pkgs.rclone ];
        script = ''
          dests=("gdrive-batchfiles-crypt:/Cryptocurrency Wallets" "dropbox-crypt:/Cryptocurrency Wallets")
          for dest in "''${dests[@]}"; do
              rclone --config /etc/nixos/rclone.conf \
                    sync -vv \
                    '/mnt/storage/Kevin/Personal/Documents/Cryptocurrency Wallets' \
                    "$dest"
          done
        '';
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

          rclone --config /etc/nixos/rclone.conf \
                sync /mnt/storage/Kevin gsuite-mysmccd-crypt:/Data/current \
                --backup-dir "gsuite-mysmccd-crypt:/Data/old/$monthly_backup_dir" \
                --bwlimit 8650k --transfers 32 --checkers 32 \
                --suffix "$backup_suffix" \
                --exclude '/Computing/Data/**' \
                --exclude '/Incoming/**' \
                --exclude 'node_modules/**' \
                --exclude '.fuse_hidden*' \
                --delete-excluded
          rclone --config /etc/nixos/rclone.conf \
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
          borg create "$repo::{hostname}-keys-{utcnow}" /etc/nixos \
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
        unitConfig.RequiresMountsFor = [ "/" ];
        startAt = "daily";
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
          rclone --config /etc/nixos/rclone.conf sync --verbose --drive-formats ods,odt,odp,svg "gsuite-school:10th Grade/Acton Gas Leak Area Data" "/mnt/storage/Kevin/Backups/Acton Gas Leak Data Mirror"
        '';
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          CPUSchedulingPolicy = "idle";
          IOSchedulingClass = "idle";
          User = "kevin";
        };
        unitConfig = {
          RequiresMountsFor = [ "/mnt/storage" ];
        };
        startAt = "daily";
      };

      systemd.services.keyboard-reset = {
        description = "Keyboard Reset";
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
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        wantedBy = [ "multi-user.target" ];
      };

      # Fonts
      fonts.fontconfig.allowBitmaps = false;
      fonts.fonts = with pkgs; [ inconsolata liberation_ttf ];

      nixpkgs.config.packageOverrides = pkgs: rec {
        factorio = pkgs.factorio.override {
          username = "Pneumaticat";
          password = "***REMOVED***";
        };
      };

      # Virtualization (VFIO & Docker)
      virtualisation.docker.enable = true;
      virtualisation.docker.autoPrune.enable = true;
      virtualisation.docker.liveRestore = false;
      systemd.services.docker.restartIfChanged = false;

    };
}
