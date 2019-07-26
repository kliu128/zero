{ config, lib, pkgs, ... }:

{
  # Home manager
  imports = [
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"

    ./android.nix
    ./audio
    ./dotnet.nix
    ./emacs
    ./firefox.nix
    ./flatpak.nix
    ./fonts.nix
    ./games.nix
    ./gpg.nix
    ./kde.nix
    ./java.nix
    ./keybase.nix
    ./kubernetes.nix
    ./nixops.nix
    ./npm.nix
    ./python.nix
    ./syncthing.nix
    ./trash.nix
    ./u2f.nix
    ./wincompat.nix
  ];
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
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

  programs.chromium.enable = true;
  users.extraUsers.kevin.extraGroups = [ "input" ];

  environment.systemPackages = with pkgs; [
    # System tools
    atop borgbackup cowsay dnsutils file fortune hdparm htop iftop iotop lm_sensors lolcat man-pages opentimestamps-client p7zip rustup smartmontools spectre-meltdown-checker stress-ng telnet thefuck tree vim wget
    # Desktop applications
    calibre chromium discord filezilla gpodder libreoffice-fresh liferea pavucontrol gnome3.pomodoro thunderbird tor-browser-bundle-bin transmission_gtk transgui vlc vscodium youtube-dl zoom-us
    # Anki and related packages (for LaTeX support)
    anki polar-bookshelf texlive.combined.scheme-basic tetex
    # Desktop tools
    appimage-run
    # KDE applications
    # Development
    bfg-repo-cleaner docker docker_compose gcc git-crypt gnumake insomnia
    # VM and DevOps
    ansible vagrant virtmanager
  ];
  
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
        key = "B351E549821994C7B843BB0F5A824102DFE3DD86";
        signByDefault = true;
      };
      extraConfig = {
        credential.helper = "libsecret";
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
        carta = {
          hostname = "potatofrom.space";
          user = "kevin";
          port = 846;
        };
        coder = {
          hostname = "rem.i.potatofrom.space";
          user = "kevin";
          port = 1843;
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

    # Visual Studio Code config
    home.file.".config/Code/User/settings.json" = {
      text = ''
        {
          "git.enableSmartCommit": true,
          "workbench.colorTheme": "Solarized Light",
          "files.autoSave": "off",
          "update.mode": "none",
          "telemetry.enableTelemetry": false,
          "editor.fontFamily": "Fira Code",
          "editor.fontLigatures": true,
          "editor.wordWrap": "on",
          "editor.tabSize": 2,
          "window.titleBarStyle": "custom",
          "typescript.updateImportsOnFileMove.enabled": "always",
          "editor.suggestSelection": "first"
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
      theme = "gnzh";
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

      alias archive=/mnt/storage/Kevin/Personal/Code/ArchiveBox/archive

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
