{ config, lib, pkgs, ... }:

{
  # Fonts
  fonts.fontconfig.allowBitmaps = false;
  fonts.fonts = with pkgs; [ inconsolata liberation_ttf ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Keyboard layout
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  services.xserver.xkbOptions = "ctrl:nocaps";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Video.
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.opengl.driSupport32Bit = true; # for steam and wine

  services.xserver.displayManager.sddm.enable = true;

  services.emacs.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    extraPackages = with pkgs; [ blueman compton conky i3lock nitrogen redshift rofi system-config-printer scrot xautolock xcape xorg.xmodmap termite udiskie ];
  };
  services.xserver.desktopManager.plasma5.enable = true;

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

  services.syncthing = {
    enable = true;
    user = "kevin";
    dataDir = "/home/kevin/.config/syncthing";
  };
  networking.firewall.allowedTCPPorts = [ 22000 ];

  services.flatpak.enable = true;

  programs.chromium.enable = true;
  programs.sway.enable = true;
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-gtk;
  environment.systemPackages = with pkgs; [
    # System tools
    i7z atop bcachefs-tools beets borgbackup cointop cowsay ctop dnsutils file fortune python36Packages.glances gnupg hdparm htop iftop iotop python python3 libva-full lm_sensors lolcat looking-glass-client lzip mpw nheko oh-my-zsh openjdk python36Packages.tvnamer rclone restic rustup screen smartmontools snapraid spectre-meltdown-checker stress-ng telnet tmux tree uptimed vim vnstat wget unar
    # Desktop applications
    android-studio arduino atom calibre cantata chromium clementine codeblocks discord electron-cash emacs filezilla firebird-emu firefox gpodder hexchat jetbrains.idea-community jetbrains.pycharm-community liferea mate.atril mkvtoolnix mpv pavucontrol skypeforlinux simple-scan slack thunderbird tor-browser-bundle transmission_gtk transmission_remote_gtk vlc vscode wine winetricks youtube-dl zoom-us
    # Desktop tools
    autokey barrier
    # KDE applications
    ark kate okular partition-manager spectacle
    # Development
    bfg-repo-cleaner gcc gdb git-crypt gitAndTools.gitFull gnumake google-cloud-sdk
    # Games
    dolphinEmuMaster multimc steam steam-run-native
    # Desktop theme
    arc-theme dunst papirus-icon-theme libsForQt5.qtstyleplugins
    # VM and DevOps
    helmfile kubernetes-helm nixops virtmanager
  ];
  environment.variables = {
    "GPODDER_HOME" = "/home/kevin/.config/gPodder";
    "GPODDER_DOWNLOAD_DIR" = "/mnt/storage/Kevin/Audio/Podcasts";
    # Use system Qt theme for Calibre
    "CALIBRE_USE_SYSTEM_THEME" = "true";
  };

  # Audio
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraConfig = ''
    load-module module-switch-on-connect
  '';

  nixpkgs.config.packageOverrides = pkgs: rec {
    dolphinEmuMaster = pkgs.dolphinEmuMaster.override {
      # Use Cool and New Qt GUI instead of WX
      # https://dolphin-emu.org/blog/2018/05/02/legend-dolphin-lens-between-worlds/
      dolphin-wxgui = false;
      dolphin-qtgui = true;
    };
    factorio = pkgs.factorio.override {
      username = "Pneumaticat";
      password = builtins.readFile ./secrets/factorio-password.txt;
    };
    wine = pkgs.wine.override {
      wineRelease = "staging";
      wineBuild = "wineWow";
    };
  };

  hardware.bluetooth.enable = true;
  users.extraUsers.kevin.extraGroups = [ "input" "sway" "wireshark" ];

  services.mpd = {
    enable = true;
    user = "kevin";
    group = "users";
    musicDirectory = "/mnt/storage/Kevin/Audio/Music";
    extraConfig = ''
      audio_output {
        type    "pulse"
        name    "Local MPD"
        server  "127.0.0.1"
      }
    '';
  };
  hardware.pulseaudio.tcp.enable = true;
}
