{ config, lib, pkgs, ... }:

{
  # Home manager
  imports = [
    "${(builtins.fetchTarball {
      url = "https://github.com/rycee/home-manager/archive/450571056552c9311fcb2894328696b535265593.tar.gz";
      sha256 = "1rlv234m0bqj9x2y9wnl8z3yq8mixzq8332nqlb8fw9k8mazis6s";
    })}/nixos"
    (builtins.fetchTarball {
      url = "https://github.com/msteen/nixos-vsliveshare/archive/e6ea0b04de290ade028d80d20625a58a3603b8d7.tar.gz";
      sha256 = "12riba9dlchk0cvch2biqnikpbq4vs22gls82pr45c3vzc3vmwq9";
    })

    ./android.nix
    ./audio
    ./chromium.nix
    ./dm.nix
    ./dotnet.nix
    ./emacs
    ./firefox.nix
    ./flatpak.nix
    ./fonts.nix
    ./games.nix
    ./gpg.nix
    ./input.nix
    ./java.nix
    ./kdeconnect.nix
    ./keybase.nix
    ./kubernetes.nix
    ./nixops.nix
    ./python.nix
    ./rice
    ./rust.nix
    ./syncthing.nix
    ./trash.nix
    ./u2f.nix
    ./wincompat.nix
    ./yarn.nix
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

  environment.systemPackages = with pkgs; [
    # System tools
    atop beets borgbackup cowsay dnsutils file fortune google-cloud-sdk hdparm htop iftop iotop lm_sensors lolcat man-pages opentimestamps-client p7zip schedtool smartmontools spectre-meltdown-checker stress-ng telnet thefuck tree vim wget
    # Desktop applications
    calibre clementine discord filezilla gpodder krita libreoffice-fresh pavucontrol gnome3.pomodoro thunderbird transmission_gtk vscodium youtube-dl zim
    # Screen recording tools
    ffmpeg-full kdenlive wf-recorder
    # Anki and related packages (for LaTeX suppfort)
    anki polar-bookshelf 
    texlive.combined.scheme-full
    # Desktop tools
    appimage-run
    # Development
    bfg-repo-cleaner docker docker_compose gcc git-crypt gnumake insomnia
    # VM and DevOps
    ansible vagrant virtmanager
  ];

  services.vsliveshare = {
    enable = true;
    enableWritableWorkaround = true;
    enableDiagnosticsWorkaround = true;
    extensionsDir = "/home/kevin/.vscode-oss/extensions";
  };

  # Must be done on the system level (not the home-manager level) to install
  # zsh completion for packages in environment.systemPackages
  programs.zsh.enable = true;

  systemd.services.cups-browsed.enable = false;

  home-manager.users.kevin = {
    programs.home-manager.enable = true;
    home.stateVersion = "18.09";

    programs.git = {
      enable = true;
      userName = "Kevin Liu";
      userEmail = "kevin@kliu.io";
      package = pkgs.gitAndTools.gitFull;
      extraConfig = {
        credential.helper = "libsecret";
      };
    };

    programs.mpv = {
      enable = true;
      config.gpu-context = "wayland";
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
        demonbeast = {
          hostname = "demonbeast.lan";
          user = "pi";
          port = 22;
        };
        felix1 = {
          hostname = "132.145.161.120";
          user = "ubuntu";
          port = 22;
        };
        felix2 = {
          hostname = "129.213.162.194";
          user = "ubuntu";
          port = 22;
        };
        karmaxer = {
          hostname = "karmaxer.i.potatofrom.space";
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
        you = {
          hostname = "you.i.potatofrom.space";
          user = "kevin";
          port = 843;
        };
      };
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

    # ZSH
    programs.zsh.enable = true;
    programs.zsh.oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "tmux" ];
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

      export PATH=$HOME/.poetry/bin:$HOME/.cargo/bin:$PATH:$HOME/bin:$HOME/Android/Sdk/ndk-bundle:$HOME/Android/Sdk/platform-tools:$HOME/.local/bin
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
      y() {
        yarn 2>&1 "$@" --color --emoji | grep -vE '(warning|info)'
      }

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
