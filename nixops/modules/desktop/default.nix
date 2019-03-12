{ config, lib, pkgs, ... }:

{
  # Home manager
  imports = [
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"

    ./android.nix
    ./audio-bt.nix
    ./dotnet.nix
    ./emacs
    ./firefox.nix
    ./flatpak.nix
    ./fonts.nix
    ./games.nix
    ./java.nix
    ./kdeconnect.nix
    ./keybase.nix
    ./kubernetes.nix
    ./nintendo-switch.nix
    ./nixops.nix
    ./npm.nix
    ./python.nix
    ./trash.nix
    ./u2f.nix
    ./wincompat.nix
  ];
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Keyboard layout
  services.xserver.libinput.enable = true;
  services.gnome3.gvfs.enable = true;
  
  # iBus
  i18n.inputMethod = {
    enabled = "ibus";
    ibus = {
      engines = [ pkgs.ibus-engines.uniemoji pkgs.ibus-engines.libpinyin pkgs.ibus-engines.table-chinese pkgs.ibus-engines.table ];
    };
  };

  # Fwupd
  services.fwupd.enable = true;

  # Enable automatic discovery of the printer (from other linux systems with avahi running)
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.avahi.nssmdns = true; # allow .local resolving

  # Printing configuration
  services.printing.enable = true;
  services.printing.clientConf = "ServerName 10.99.0.1";

  services.syncthing = {
    enable = true;
    user = "kevin";
    dataDir = "/home/kevin/.config/syncthing";
  };
  networking.firewall.allowedTCPPorts = [ 22000 ];

  programs.chromium.enable = true;
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-gtk;
  users.extraUsers.kevin.extraGroups = [ "input" "wireshark" ];

  environment.systemPackages = with pkgs; [
    # System tools
    i7z atop borgbackup cowsay dnsutils file fortune gnupg hdparm htop iftop iotop lm_sensors lolcat p7zip rustup smartmontools spectre-meltdown-checker stress-ng telnet thefuck tree vim wget
    # Desktop applications
    calibre chromium clementine cool-retro-term discord emacs libreoffice-still liferea pavucontrol thunderbird transmission_gtk transmission_remote_gtk vlc vscode youtube-dl zoom-us
    # Anki and related packages (for LaTeX support)
    anki texlive.combined.scheme-basic tetex
    # Desktop tools
    appimage-run
    # KDE applications
    # Development
    bfg-repo-cleaner docker docker_compose gcc git-crypt gnumake
    # VM and DevOps
    virtmanager
    # Desktop environment
    arc-kde-theme gnome3.cheese mate.atril kitty
    ark unar kate partition-manager spectacle kdesu kcalc
    # Image editing
    gwenview krita
  ];

  environment.variables.GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  
  # Must be done on the system level (not the home-manager level) to install
  # zsh completion for packages in environment.systemPackages
  programs.zsh.enable = true;

  home-manager.users.kevin = {
    programs.home-manager.enable = true;

    home.file.".config/kitty/kitty.conf".text = ''
      font_family Fira Code
      enable_audio_bell no

      # Base16 Unikitty Dark - kitty color config
      # Josh W Lewis (@joshwlewis)
      background #2e2a31
      foreground #bcbabe
      selection_background #bcbabe
      selection_foreground #2e2a31
      url_color #9f9da2
      cursor #bcbabe

      # normal
      color0 #2e2a31
      color1 #d8137f
      color2 #17ad98
      color3 #dc8a0e
      color4 #796af5
      color5 #bb60ea
      color6 #149bda
      color7 #bcbabe

      # bright
      color8 #838085
      color9 #d8137f
      color10 #17ad98
      color11 #dc8a0e
      color12 #796af5
      color13 #bb60ea
      color14 #149bda
      color15 #bcbabe

      # extended base16 colors
      color16 #d65407
      color17 #c720ca
      color18 #4a464d
      color19 #666369
      color20 #9f9da2
      color21 #d8d7da
    '';

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

    home.file.".local/share/thunderbird-signature.png".source = ./signature.html;

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
          hostname = "otto.i.potatofrom.space";
          user = "kevin";
          port = 843;
        };
        puck = {
          hostname = "puck.i.potatofrom.space";
          user = "kevin";
          port = 843;
        };
        rem = {
          hostname = "rem.i.potatofrom.space";
          user = "kevin";
          port = 843;
        };
        assuna = {
          hostname = "192.168.1.9";
          user = "kevin";
          port = 22;
        };
        subaru = {
          hostname = "35.211.16.173";
          port = 22;
          user = "kevin";
        };
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

    # Visual Studio Code config
    home.file.".config/Code/User/settings.json" = {
      text = ''
        {
          "team.showWelcomeMessage": false,
          "git.enableSmartCommit": true,
          "workbench.colorTheme": "Solarized Light",
          // Suppress the warning that the .NET CLI is not on the path.
          "csharp.suppressDotnetInstallWarning": true,
          "files.autoSave": false,
          "telemetry.enableTelemetry": false,
          "workbench.iconTheme": "vs-nomo-dark",
          "editor.fontFamily": "Fira Code",
          "editor.fontLigatures": true,
          "editor.wordWrap": "on",
          "editor.tabSize": 2,
          "window.titleBarStyle": "custom"
        }
      '';
    };

    programs.tmux = {
      enable = true;
      extraConfig = ''
        # Fix ESC key delay
        set -s escape-time 0

        # if run as "tmux attach", create a session if one does not already exist
        new-session -n $HOST

        # enable mouse
        set -g mouse on

        set -g default-terminal "tmux-256color"
      '';
    };

    # GTK & Qt
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Light";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "Arc";
        package = pkgs.arc-theme;
      };
    };
    qt = {
      enable = true;
      useGtkTheme = true;
    };

    pam.sessionVariables = {
      GPODDER_HOME = "/home/kevin/.config/gPodder";
      GPODDER_DOWNLOAD_DIR = "/mnt/storage/Kevin/Audio/Podcasts";
      # Use system Qt theme for Calibre
      CALIBRE_USE_SYSTEM_THEME = "true";
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
      plugins = [ "git" ];
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

      archive() {
        pushd /mnt/storage/Kevin/Personal/Code/ArchiveBox
        echo Sending links $@ to Docker archiver
        echo $@ | docker-compose exec -T archivebox /bin/archive
        popd
      }

      export PATH=$HOME/.cargo/bin:$PATH:$HOME/bin:$HOME/Android/Sdk/ndk-bundle:$HOME/Android/Sdk/platform-tools:$HOME/.local/bin
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
