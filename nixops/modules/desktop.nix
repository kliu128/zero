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
          hostname = "emilia.lan";
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
          hostname = "otto.lan";
          user = "kevin";
          port = 22;
        };
        puck = {
          hostname = (import ../wireguard.nix).ips.puck;
          user = "kevin";
          port = 843;
        };
        subaru = {
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
          // Set the default
          "editor.formatOnSave": true,
          "[json]": {
            "editor.formatOnSave": false
          },
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

      # Enable 256-color mode
      set -g default-terminal "screen-256color"

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
    home.packages = with pkgs; [
      # System tools
      i7z atop bcachefs-tools beets borgbackup cointop cowsay ctop dnsutils file fortune python36Packages.glances gnupg hdparm htop iftop iotop python python3 libva-full lm_sensors lolcat looking-glass-client lzip mpw nheko oh-my-zsh openjdk python36Packages.tvnamer rclone restic rustup screen smartmontools snapraid spectre-meltdown-checker stress-ng telnet thefuck tmux tree vim wget wireguard unar
      # Desktop applications
      android-studio arduino atom calibre cantata chromium clementine codeblocks discord emacs filezilla firebird-emu gnome3.gnome-disk-utility google-chrome gpodder hexchat jetbrains.idea-community jetbrains.pycharm-community keepassxc latest.firefox-nightly-bin liferea mate.atril mkvtoolnix mpv pavucontrol skypeforlinux simple-scan slack thunderbird tor-browser-bundle transmission_gtk transmission_remote_gtk vlc vscode wine winetricks youtube-dl zoom-us
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
      arandr blueman conky i3lock nitrogen pcmanfm system-config-printer scrot xautolock xcape xcompmgr termite
    ];
    pam.sessionVariables = {
      GPODDER_HOME = "/home/kevin/.config/gPodder";
      GPODDER_DOWNLOAD_DIR = "/mnt/storage/Kevin/Audio/Podcasts";
      # Use system Qt theme for Calibre
      CALIBRE_USE_SYSTEM_THEME = "true";
    };

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      config.bars = [ ];
      extraConfig = ''
        ### Variables
        #
        # Logo key. Use Mod1 for Alt.
        set $mod Mod4
        # Home row direction keys, like vim
        set $left h
        set $down j
        set $up k
        set $right l
        # Your preferred terminal emulator
        set $term termite --exec "tmux attach"
        # Your preferred application launcher
        set $menu exec i3-dmenu-desktop --dmenu='rofi -show run -font "Source Code Pro 11"'

        font pango:Source Code Pro 10

        #
        # Example configuration:
        #
        #   output HDMI-A-1 resolution 1920x1080 position 1920,0
        #
        # You can get the names of your outputs by running: swaymsg -t get_outputs

        ### Input configuration
        #
        # Example configuration:
        #
        #   input "2:14:SynPS/2_Synaptics_TouchPad" {
        #       dwt enabled
        #       tap enabled
        #       natural_scroll enabled
        #       middle_emulation enabled
        #   }
        #
        # You can get the names of your inputs by running: swaymsg -t get_inputs
        # Read `man 5 sway-input` for more information about this section.

        # BASIC KEY BINDINGS
        # ==================
            # start a terminal
            bindsym $mod+Return exec $term

            # kill focused window
            bindsym $mod+Shift+q kill

            # start your launcher
            bindsym $mod+d exec $menu

            # Drag floating windows by holding down $mod and left mouse button.
            # Resize them with right mouse button + $mod.
            # Despite the name, also works for non-floating windows.
            # Change normal to inverse to use left mouse button for resizing and right
            # mouse button for dragging.
            floating_modifier $mod

            # reload the configuration file
            bindsym $mod+Shift+c reload

            # exit sway (logs you out of your wayland session)
            bindsym $mod+Shift+e exit

        # MOVING AROUND
        # =============
            # Move your focus around
            bindsym $mod+$left focus left
            bindsym $mod+$down focus down
            bindsym $mod+$up focus up
            bindsym $mod+$right focus right
            # or use $mod+[up|down|left|right]
            bindsym $mod+Left focus left
            bindsym $mod+Down focus down
            bindsym $mod+Up focus up
            bindsym $mod+Right focus right

            # _move_ the focused window with the same, but add Shift
            bindsym $mod+Shift+$left move left
            bindsym $mod+Shift+$down move down
            bindsym $mod+Shift+$up move up
            bindsym $mod+Shift+$right move right
            # ditto, with arrow keys
            bindsym $mod+Shift+Left move left
            bindsym $mod+Shift+Down move down
            bindsym $mod+Shift+Up move up
            bindsym $mod+Shift+Right move right

        # WORKSPACES
        # ==========

            # switch to workspace
            bindsym $mod+1 workspace 1
            bindsym $mod+2 workspace 2
            bindsym $mod+3 workspace 3
            bindsym $mod+4 workspace 4
            bindsym $mod+5 workspace 5
            bindsym $mod+6 workspace 6
            bindsym $mod+7 workspace 7
            bindsym $mod+8 workspace 8
            bindsym $mod+9 workspace 9
            bindsym $mod+0 workspace 10
            # move focused container to workspace
            bindsym $mod+Shift+1 move container to workspace 1
            bindsym $mod+Shift+2 move container to workspace 2
            bindsym $mod+Shift+3 move container to workspace 3
            bindsym $mod+Shift+4 move container to workspace 4
            bindsym $mod+Shift+5 move container to workspace 5
            bindsym $mod+Shift+6 move container to workspace 6
            bindsym $mod+Shift+7 move container to workspace 7
            bindsym $mod+Shift+8 move container to workspace 8
            bindsym $mod+Shift+9 move container to workspace 9
            bindsym $mod+Shift+0 move container to workspace 10
            # Note: workspaces can have any name you want, not just numbers.
            # We just use 1-10 as the default.

        # LAYOUT NAVIGATION
        # =================
        # You can "split" the current object of your focus with
        # $mod+b or $mod+v, for horizontal and vertical splits
        # respectively.
        bindsym $mod+b splith
        bindsym $mod+v splitv

        # Switch the current container between different layout styles
        bindsym $mod+s layout stacking
        bindsym $mod+w layout tabbed
        bindsym $mod+e layout toggle split

        # Make the current focus fullscreen
        bindsym $mod+f fullscreen

        # Toggle the current focus between tiling and floating mode
        bindsym $mod+Shift+space floating toggle

        # Swap focus between the tiling area and the floating area
        bindsym $mod+space focus mode_toggle

        # move focus to the parent container
        bindsym $mod+a focus parent

        #
        # SCRATCHPAD
        # ==========
        # i3 has a "scratchpad", which is a bag of holding for windows.
        # You can send windows there and get them back later.

        # Move the currently focused window to the scratchpad
        bindsym $mod+Shift+minus move scratchpad

        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        bindsym $mod+minus scratchpad show

        # MOD+R RESIZE
        # ============
        mode "resize" {
            # left will shrink the containers width
            # right will grow the containers width
            # up will shrink the containers height
            # down will grow the containers height
            bindsym $left resize shrink width 10 px or 10 ppt
            bindsym $down resize grow height 10 px or 10 ppt
            bindsym $up resize shrink height 10 px or 10 ppt
            bindsym $right resize grow width 10 px or 10 ppt

            # ditto, with arrow keys
            bindsym Left resize shrink width 10 px or 10 ppt
            bindsym Down resize grow height 10 px or 10 ppt
            bindsym Up resize shrink height 10 px or 10 ppt
            bindsym Right resize grow width 10 px or 10 ppt

            # return to default mode
            bindsym Return mode "default"
            bindsym Escape mode "default"
        }
        bindsym $mod+r mode "resize"

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

        # BORDERS & GAPS
        # ==============
        for_window [class="^.*"] border pixel 2
        gaps inner 4
        gaps outer 6

        # BOILERPLATE DESKTOP STARTUP
        # ===========================
        exec nitrogen --restore
        exec xcape
        exec --no-startup-id xautolock -time 5 -locker "i3lock" -corners ----
        exec --no-startup-id xset s 290
        bindsym Pause exec xautolock -locknow && sleep 5 && xset dpms force off
        exec xcompmgr
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
