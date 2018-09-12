{ config, lib, pkgs, ... }:

with import <nixpkgs> {};
with lib;

{
  # Fonts
  fonts.fontconfig.allowBitmaps = false;
  fonts.fonts = with pkgs; [ emojione powerline-fonts inconsolata liberation_ttf ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Keyboard layout
  services.xserver.libinput.enable = true;

  # Fwupd
  services.fwupd.enable = true;

  hardware.opengl.driSupport32Bit = true; # for steam and wine

  # Scanner
  hardware.sane.enable = true;

  # Enable automatic discovery of the printer (from other linux systems with avahi running)
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.avahi.nssmdns = true; # allow .local resolving

  # Printing configuration
  services.printing.enable = true;
  services.printing.clientConf = "ServerName ${(import ../wireguard.nix).ips.rem}";

  services.syncthing = {
    enable = true;
    user = "kevin";
    dataDir = "/home/kevin/.config/syncthing";
  };
  networking.firewall.allowedTCPPorts = [ 22000 ];

  services.flatpak.enable = true;
  programs.adb.enable = true;
  programs.chromium.enable = true;
  services.emacs.enable = true;
  programs.sway.enable = true;
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-gtk;
  users.extraUsers.kevin.extraGroups = [ "input" "sway" "wireshark" ];

  # Audio
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraConfig = ''
    load-module module-switch-on-connect
  '';

  # Custom package overrides
  nixpkgs.config.packageOverrides = pkgs: rec {
    winetricks = pkgs.winetricks.override { wine = pkgs.wineWowPackages.staging; };
    factorio = pkgs.factorio.override {
      username = "Pneumaticat";
      password = builtins.readFile ./secrets/factorio-password.txt;
    };
    myEclipse = with pkgs.eclipses; eclipseWithPlugins {
      eclipse = eclipse-sdk;
      plugins = [ plugins.color-theme ];
    };
  };
  nixpkgs.config.chromium.enableAdobeFlash = true;

  hardware.bluetooth.enable = true;

  # MPD configuration
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

  # Home manager
  imports = [
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
  ];
  nixpkgs.overlays = [
    (import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz))
  ];

  environment.systemPackages = with pkgs; [
    # System tools
    i7z atop bcachefs-tools beets borgbackup cointop cowsay ctop dnsutils file fortune python36Packages.glances gnupg hdparm htop iftop iotop python python3 libva-full lm_sensors lolcat looking-glass-client lzip mpw nheko oh-my-zsh openjdk python36Packages.tvnamer rclone restic rustup screen smartmontools snapraid spectre-meltdown-checker stress-ng telnet thefuck tmux tree vim wget wireguard unar
    # Desktop applications
    android-studio anki arduino atom calibre cantata chromium clementine codeblocks discord emacs filezilla firebird-emu firefox gnome3.gnome-disk-utility google-chrome gpodder hexchat jetbrains.idea-community jetbrains.pycharm-community keepassxc libreoffice-fresh liferea mate.atril mkvtoolnix mpv myEclipse pavucontrol skypeforlinux simple-scan slack thunderbird tor-browser-bundle transmission_gtk transmission_remote_gtk vlc vscode wineWowPackages.staging winetricks youtube-dl zoom-us
    # Anki and related packages (for LaTeX support)
    anki texlive.combined.scheme-basic tetex
    # Desktop tools
    appimage-run autokey barrier
    # KDE applications
    ark kate okular partition-manager spectacle
    # Development
    bfg-repo-cleaner docker docker_compose docker-machine gcc gdb git-crypt gitAndTools.gitFull gnumake google-cloud-sdk
    # Games
    dolphinEmuMaster multimc steam steam-run-native
    # VM and DevOps
    helmfile kubectl kubernetes-helm nixops virtmanager
    # Desktop environment
    arandr blueman conky gnome3.nautilus i3lock system-config-printer scrot xautolock xcape xcompmgr termite
    # Image editing
    gwenview krita
  ];

  services.dbus.packages = [ pkgs.gnome3.dconf ];

  # Must be done on the system level (not the home-manager level) to install
  # zsh completion for packages in environment.systemPackages
  programs.zsh.enable = true;

  home-manager.users.kevin = {
    programs.home-manager.enable = true;
    programs.git = {
      enable = true;
      userName = "Kevin Liu";
      userEmail = "kevin@potatofrom.space";
      package = pkgs.gitAndTools.gitFull;
      signing = {
        key = "8792E2260F507DA00F0DB58E2160C3EB40A944EC";
        signByDefault = true;
      };
    };
    programs.htop = {
      enable = true;
      accountGuestInCpuMeter = true;
      detailedCpuTime = true;
      hideKernelThreads = false;
      hideUserlandThreads = true;
      hideThreads = true;
    };
    programs.rofi = {
      enable = true;
      theme = "purple";
    };
    programs.ssh = {
      enable = true;
      matchBlocks = {
        emilia = {
          hostname = "192.168.1.6";
          user = "kevin";
          port = 22;
        };
        demonbeast = {
          hostname = "demonbeast.lan";
          user = "pi";
          port = 22;
        };
        karmaxer = {
          hostname = "server.scintillate.me";
          user = "kevin";
          port = 843;
        };
        otto = {
          hostname = "192.168.1.11";
          user = "kevin";
          port = 843;
        };
        puck = {
          hostname = (import ../wireguard.nix).ips.puck;
          user = "kevin";
          port = 843;
        };
        rem = {
          hostname = (import ../wireguard.nix).ips.rem;
          user = "kevin";
          port = 843;
        };
        assuna = {
          hostname = "server.scintillate.me";
          user = "kevin";
          port = 844;
        };
      };
    };

    # Desktop services
    services.dunst.enable = true;
    services.dunst.settings = {
      global = {
        follow = "mouse";
        geometry = "300x5-30+20";
        indicate_hidden = true;
        shrink = false;
        transparency = 0;
        notification_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 3;
        frame_color = "#AAAAAA";
        separator_color = "auto";
        sort = true;
        font = "Monospace 10";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = true;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
      };
    };
    services.gpg-agent.enable = true;
    services.redshift = {
      enable = true;
      provider = "manual"; # Provide own longitude + latitude
      latitude = "42";
      longitude = "-71";
      tray = true;
    };
    services.udiskie = {
      enable = true;
      tray = "always";
    };

    # Visual Studio Code config
    home.file.".config/Code/User/settings.json" = {
      text = ''
        {
          "team.showWelcomeMessage": false,
          "git.enableSmartCommit": true,
          "workbench.colorTheme": "Kimbie Dark",
          // Suppress the warning that the .NET CLI is not on the path.
          "csharp.suppressDotnetInstallWarning": true,
          "files.autoSave": "onFocusChange",
          "telemetry.enableTelemetry": false,
          "workbench.iconTheme": "vs-nomo-dark",
          "editor.wordWrap": "on",
          "editor.tabSize": 2
        }
      '';
    };

    home.file.".tmux.conf".text = ''
      # Fix ESC key delay
      set -s escape-time 0

      # if run as "tmux attach", create a session if one does not already exist
      new-session -n $HOST

      # enable mouse
      set -g mouse on
    '';

    home.file.".conkyrc".text = builtins.readFile ./desktop/.conkyrc;

    # Emacs
    home.file.".spacemacs".text = builtins.readFile ./desktop/.spacemacs;
    home.file.".emacs.d" = {
      source = fetchFromGitHub {
        owner = "syl20bnr";
        repo = "spacemacs";
        rev = "45ee95c289adaba6f7eff0c2564756ea41d9fb15";
        sha256 = "16yn14cxvdj8salaf3x3mabbbs5kr94v6d9sd5paxd51c69mnx1x";
      };
      recursive = true;
    };
    home.file.".spacemacs.d/next-spec-day.el".text = builtins.readFile ./desktop/next-spec-day.el;

    # GTK & Qt
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "Arc-Dark";
        package = pkgs.arc-theme;
      };
    };
    qt = {
      enable = true;
      useGtkTheme = true;
    };

    # i3
    xsession.enable = true;
    xsession.initExtra = ''
      # Start polkit agent to allow for superuser operations
      ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
    '';
    pam.sessionVariables = {
      GPODDER_HOME = "/home/kevin/.config/gPodder";
      GPODDER_DOWNLOAD_DIR = "/mnt/storage/Kevin/Audio/Podcasts";
      # Use system Qt theme for Calibre
      CALIBRE_USE_SYSTEM_THEME = "true";
    };

    xsession.windowManager.i3 = let
      modifier = "Mod4";
    in {
      enable = true;
      package = pkgs.i3-gaps;
      config = {
        bars = [ ];
        fonts = [ "pango: Source Code Pro 10" ];
        gaps = {
          inner = 4;
          outer = 6;
        };
        keybindings = mkOptionDefault {
          # Extend default i3 binds

          # Vim movement
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";

          # Vim movement for windows
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";

          # Menu and term
          "${modifier}+d" = ''exec i3-dmenu-desktop --dmenu='rofi -show run -font "Source Code Pro 11"' '';
          "${modifier}+Return" = "exec termite --exec 'tmux attach'";

          # Scratchpad
          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";

          # Locking
          "Pause" = "exec xautolock -locknow && sleep 5 && xset dpms force off";
        };
        modifier = modifier;
        startup = [
          { command = "nitrogen --restore"; notification = false; }
          { command = "xcape"; notification = false; }
          { command = ''xautolock -time 5 -locker "i3lock" -corners ----''; notification = false; }
          { command = "xset s 290"; notification = false; }
          { command = "xcompmgr"; notification = false; }
          { command = "autokey-gtk"; notification = false; }
        ];
      };
      extraConfig = ''
        # COLORS & BAR
        # ============
        # Base16 Unikitty by Josh W Lewis (@joshwlewis)
        # template by Matt Parnell, @parnmatt

        set $base00 #2e2a31
        set $base01 #4b484e
        set $base02 #69666b
        set $base03 #878589
        set $base04 #a5a3a6
        set $base05 #c3c2c4
        set $base06 #e1e0e1
        set $base07 #ffffff
        set $base08 #d8137f
        set $base09 #d65407
        set $base0A #dc8a0e
        set $base0B #17ad98
        set $base0C #149bda
        set $base0D #7864fa
        set $base0E #b33ce8
        set $base0F #d41acd

        client.focused $base0D $base0D $base00 $base01
        client.focused_inactive $base02 $base02 $base03 $base01
        client.unfocused $base01 $base01 $base03 $base01
        client.urgent $base02 $base08 $base07 $base08

        bar {
            status_command bash ${./desktop/conky-bar.sh}
            i3bar_command i3bar -t
            font pango:Source Code Pro
            position top
            
            colors {
                separator $base03
                background $base01
                statusline $base05
                focused_workspace $base0C $base0D $base00
                active_workspace $base02 $base02 $base07
                inactive_workspace $base01 $base01 $base03
                urgent_workspace $base08 $base08 $base07
            }
        }
      '';
    };

    # Keyboard
    home.keyboard.layout = "us";
    home.keyboard.variant = "altgr-intl";
    home.keyboard.options = [ "ctrl:nocaps" ];

    # ZSH
    programs.zsh.enable = true;
    programs.zsh.oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "tmux" "git" ];
    };
    programs.zsh.initExtra = ''
      # Colorized man
      man() {
          LESS_TERMCAP_md=$'\e[01;31m' \
          LESS_TERMCAP_me=$'\e[0m' \
          LESS_TERMCAP_se=$'\e[0m' \
          LESS_TERMCAP_so=$'\e[01;44;33m' \
          LESS_TERMCAP_ue=$'\e[0m' \
          LESS_TERMCAP_us=$'\e[01;32m' \
          command man "$@"
      }

      export PATH=$HOME/.cargo/bin:$PATH:$HOME/bin:$HOME/Android/Sdk/ndk-bundle:$HOME/Android/Sdk/platform-tools:$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/.local/var/npm/bin
      if [[ "$DISPLAY" ]]; then
        # Use graphical emacs
        export EDITOR="emacsclient --socket-name=/tmp/emacs1000/server "
        alias emacs="$EDITOR "
      else
        # Just use vim:tm: without graphical environment
        export EDITOR="vim "
      fi
      
      # Convenient aliases
      alias k=kubectl
      # Enable yarn with emoji
      alias yarn="yarn --emoji true"

      eval $(thefuck --alias)

      # Set GPG TTY (for SSH sessions, etc.)
      export GPG_TTY=$(tty)

      # Refresh gpg-agent tty in case user switches into an X session
      gpg-connect-agent updatestartuptty /bye >/dev/null

      # MOTD
      print -P "Welcome to \e[1m\e[36m$(cat /etc/hostname)%F{reset_color}\e[0m\!"
      print -P "   Kernel: $(uname -r) ($(uname -v))%F{reset_color}"
      # show system status
      systemctl status | head -n 5 | tail -n 4

      echo ""

      # fun cowsay
      fortune | cowsay | lolcat

      echo ""
    '';
  };

  users.extraUsers.kevin.shell = pkgs.zsh;
}
