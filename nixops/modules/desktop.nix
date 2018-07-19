{ config, lib, pkgs, ... }:

{
  # Fonts
  fonts.fontconfig.allowBitmaps = false;
  fonts.fonts = with pkgs; [ powerline-fonts inconsolata liberation_ttf ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Keyboard layout
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  services.xserver.xkbOptions = "ctrl:nocaps";
  services.xserver.libinput.enable = true;

  hardware.opengl.driSupport32Bit = true; # for steam and wine

  services.emacs.enable = true;
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
    i7z atop bcachefs-tools beets borgbackup cointop cowsay ctop dnsutils file fortune python36Packages.glances gnupg hdparm htop iftop iotop python python3 libva-full lm_sensors lolcat looking-glass-client lzip mpw nheko oh-my-zsh openjdk python36Packages.tvnamer rclone restic rustup screen smartmontools snapraid spectre-meltdown-checker stress-ng telnet tmux tree vim wget unar
    # Desktop applications
    android-studio arduino atom calibre cantata chromium clementine codeblocks discord electron-cash emacs filezilla firebird-emu firefox gnome3.gnome-disk-utility gpodder hexchat jetbrains.idea-community jetbrains.pycharm-community keepassxc liferea mate.atril mkvtoolnix mpv pavucontrol skypeforlinux simple-scan slack thunderbird tor-browser-bundle transmission_gtk transmission_remote_gtk vlc vscode wine winetricks youtube-dl zoom-us
    # Desktop tools
    appimage-run autokey barrier
    # KDE applications
    ark kate okular partition-manager spectacle
    # Development
    bfg-repo-cleaner docker docker_compose docker-machine gcc gdb git-crypt gitAndTools.gitFull gnumake google-cloud-sdk
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

  # Home manager
  imports = [
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
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
      hideThreads = true;
    };
    programs.rofi = {
      enable = true;
      theme = "purple";
    };
    programs.ssh = {
      enable = true;
      matchBlocks = {
        karmaxer = {
          hostname = "server.scintillate.me";
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

    services.gpg-agent = {
      enable = true;
    };

    # i3
    xsession.enable = true;
    home.packages = with pkgs; [ blueman conky i3lock nitrogen pcmanfm redshift rofi system-config-printer scrot xautolock xcape xorg.xmodmap termite udiskie ];
    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      #extraSessionCommands = ''
      #  # Start polkit agent to allow for superuser operations
      #  ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
      #'';
      extraConfig = ''
        # Default config for sway
        #
        # Copy this to ~/.config/sway/config and edit it to your liking.
        #
        # Read `man 5 sway` for a complete reference.

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

        ### Output configuration
        #
        # Default wallpaper (more resolutions are available in /usr/share/sway/)

        workspace 1 output HDMI-A-0
        workspace 2 output DisplayPort-0
        workspace 3 output DVI-D-0

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
            status_command /home/kevin/.local/bin/conky-bar.sh
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

        # STARTUP APPLICATIONS
        # ====================
        exec --no-startup-id i3-msg 'workspace 1; exec firefox; workspace 3; layout tabbed; exec $term; exec emacsclient -c; workspace 2; layout tabbed; exec thunderbird; exec Discord'

        # BOILERPLATE DESKTOP STARTUP
        # ===========================
        exec nitrogen --restore
        exec xmodmap ~/.xmodmap.conf
        exec xcape
        exec /home/kevin/.screenlayout/layout.sh
        exec --no-startup-id dunst
        exec --no-startup-id udiskie
        exec --no-startup-id xautolock -time 5 -locker "i3lock" -corners ----
        exec --no-startup-id xset s 290
        bindsym Pause exec xautolock -locknow && sleep 5 && xset dpms force off
        '';
    };
  };
}
