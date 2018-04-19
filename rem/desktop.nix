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
    extraPackages = with pkgs; [ blueman compton conky dunst i3lock nitrogen redshift rofi system-config-printer scrot xautolock xcape xorg.xmodmap termite udiskie ];
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
    i7z atop bcachefs-tools beets borgbackup cowsay cryptop ctop dnsutils dtrx file fortune docker_compose git-crypt gitAndTools.gitFull gnupg hdparm htop iftop iotop p7zip python python3 libva-full lm_sensors lolcat looking-glass-client lzip mpw nheko oh-my-zsh openjdk python36Packages.tvnamer rclone restic rustup screen smartmontools snapraid spectre-meltdown-checker stress-ng telnet tmux tree uptimed vim vnstat wget zip unar unzip
    # Desktop applications
    android-studio atom calibre chromium clementineUnfree codeblocks discord electron-cash emacs gnome3.gedit gnome3.nautilus filezilla firefox gpodder hexchat jetbrains.idea-community jetbrains.pycharm-community libreoffice-fresh liferea mate.atril mkvtoolnix mpv multimc pavucontrol simple-scan slack spectacle thunderbird transmission_gtk transmission_remote_gtk vlc vscode wine winetricks youtube-dl
    # Development
    gcc gdb gnumake
    # Games
    steam steam-run-native
    # Desktop theme
    arc-theme papirus-icon-theme
    # VM
    nixops virtmanager
  ];
  environment.variables = {
    "GPODDER_HOME" = "/home/kevin/.config/gPodder";
    "GPODDER_DOWNLOAD_DIR" = "/mnt/storage/Kevin/Audio/Podcasts";
  };

  # Audio
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraConfig = ''
    load-module module-switch-on-connect
  '';

  nixpkgs.config.packageOverrides = pkgs: rec {
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
}