{ config, lib, pkgs, ... }:

{
  programs.chromium.enable = true;
  programs.sway.enable = true;
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-gtk;
  environment.systemPackages = with pkgs; [
    # System tools
    i7z atop bcachefs-tools beets borgbackup cowsay cryptop ctop dnsutils dtrx file fortune docker_compose gcc gitAndTools.gitFull gnupg hdparm htop iftop iotop p7zip python python3 libva-full lm_sensors lolcat looking-glass-client lzip mpw nheko oh-my-zsh openjdk python36Packages.tvnamer rclone restic rustup screen smartmontools snapraid spectre-meltdown-checker stress-ng telnet tmux tree uptimed vim vnstat wget zip unar unzip
    # Desktop applications
    android-studio atom calibre chromium clementineUnfree codeblocks discord electron-cash emacs gnome3.gedit gnome3.nautilus filezilla firefox gpodder hexchat jetbrains.idea-community jetbrains.pycharm-community libreoffice-fresh liferea mate.atril mkvtoolnix mpv multimc pavucontrol simple-scan slack spectacle thunderbird transmission_gtk transmission_remote_gtk vlc vscode wineStaging winetricks youtube-dl
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

  hardware.bluetooth.enable = true;
}