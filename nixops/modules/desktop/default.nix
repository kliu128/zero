{ config, lib, pkgs, ... }:

with import <nixpkgs> {};
with lib;

{
  # Home manager
  imports = [
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"

    ./firefox.nix
    ./games.nix
    ./kubernetes.nix
    ./nintendo-switch.nix
    ./npm.nix
    ./trash.nix
    ./u2f.nix
  ];
  
  # Fonts
  fonts.fontconfig.allowBitmaps = false;
  fonts.fonts = with pkgs; [
    corefonts emojione powerline-fonts fira-code liberation_ttf source-han-serif-simplified-chinese source-han-serif-japanese source-han-serif-korean source-han-serif-traditional-chinese
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Keyboard layout
  services.xserver.libinput.enable = true;
  # iBus
  i18n.inputMethod = {
    enabled = "ibus";
    ibus = {
      engines = [ pkgs.ibus-engines.uniemoji pkgs.ibus-engines.libpinyin pkgs.ibus-engines.table-chinese pkgs.ibus-engines.table ];
    };
  };

  # Fwupd
  services.fwupd.enable = true;

  # Scanner
  hardware.sane.enable = true;

  # Enable automatic discovery of the printer (from other linux systems with avahi running)
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.avahi.nssmdns = true; # allow .local resolving

  # Printing configuration
  services.printing.enable = true;
  services.printing.clientConf = "ServerName ${(import ../../wireguard.nix).ips.rem}";

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
  
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  environment.systemPackages = with pkgs; [
    # System tools
    i7z atop bcachefs-tools beets borgbackup cointop cowsay ctop dnsutils file fortune python36Packages.glances gnupg hdparm htop iftop iotop python python3 libva-full lm_sensors lolcat looking-glass-client lzip mpw oh-my-zsh openjdk python36Packages.tvnamer rclone restic rustup screen smartmontools snapraid spectre-meltdown-checker stress-ng telnet thefuck tmux tree vim wget wireguard unar
    # Desktop applications
    android-studio arduino atom calibre chromium clementine codeblocks discord emacs filezilla firebird-emu gnome3.gnome-disk-utility google-chrome gpodder hexchat jetbrains.idea-community jetbrains.pycharm-community keepassxc libreoffice-fresh liferea mate.atril mkvtoolnix mpv pavucontrol skypeforlinux simple-scan slack thunderbird tor-browser-bundle transmission_gtk transmission_remote_gtk vlc vscode youtube-dl zoom-us
    # Anki and related packages (for LaTeX support)
    anki texlive.combined.scheme-basic tetex
    # Desktop tools
    appimage-run autokey barrier
    # KDE applications
    kate okular partition-manager spectacle
    # Development
    bfg-repo-cleaner docker docker_compose docker-machine gcc gdb git-crypt gitAndTools.gitFull gnumake google-cloud-sdk
    # VM and DevOps
    nixops virtmanager
    # Desktop environment
    arandr blueman gnome3.cheese conky pcmanfm gnome3.file-roller gvfs i3lock p7zip system-config-printer scrot xautolock xcape
    # Image editing
    gwenview krita
  ];

  environment.variables.GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];

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
      extraConfig = ''
        [init]
        templatedir = /home/kevin/.git-templates
      '';
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
          hostname = "192.168.1.11";
          user = "kevin";
          port = 843;
        };
        puck = {
          hostname = (import ../../wireguard.nix).ips.puck;
          user = "kevin";
          port = 843;
        };
        rem = {
          hostname = (import ../../wireguard.nix).ips.rem;
          user = "kevin";
          port = 843;
        };
        assuna = {
          hostname = "server.scintillate.me";
          user = "kevin";
          port = 844;
        };
        subaru = {
          hostname = "35.211.16.173";
          port = 22;
          user = "kevin";
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
          "editor.fontFamily": "Fira Code",
          "editor.fontLigatures": true,
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

    home.file.".conkyrc".text = builtins.readFile ./.conkyrc;

    home.file.".config/alacritty/alacritty.yml".text = builtins.readFile ./alacritty.yml;

    # Emacs
    home.file.".spacemacs".text = builtins.readFile ./.spacemacs;
    home.file.".emacs.d" = {
      source = fetchFromGitHub {
        owner = "syl20bnr";
        repo = "spacemacs";
        rev = "06927bc8f075768b253d4e8ce3ac9f07c2aaddf9";
        sha256 = "06m63q1k02m18ih94qsc4bavc58pi2hschkp3db6dh28cysqva2g";
      };
      recursive = true;
    };
    home.file.".spacemacs.d/next-spec-day.el".text = builtins.readFile ./next-spec-day.el;

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
          smartGaps = true;
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
          "${modifier}+d" = ''exec "PATH=$PATH:$HOME/.local/bin rofi -combi-modi drun,run,window -show combi -modi combi -font 'Fira Code 11'"'';
          "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";

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
          #{ command = "autokey-gtk"; notification = false; }
          { command = "ibus-daemon"; notification = false; }
          { command = "kdeconnect-indicator"; notification = false; }
          { command = "${pkgs.feh}/bin/feh --bg-fill ${./bg.jpg}"; notification = false; }
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
            status_command bash ${./conky-bar.sh}
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

    # Compositor
    services.compton = {
      enable = true;
      vSync = "drm";
      fade = true;
      fadeDelta = 5;
      backend = "xrender";
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
