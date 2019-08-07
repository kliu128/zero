# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  network = {
    description = "Re:Zero Production™ Cluster";
    enableRollback = true;
  };
  
  defaults = {
    imports = [
      ./common/firewall.nix
      ./common/kernel.nix
      ./common/nix.nix
      ./common/security.nix
      ./common/ssh.nix
      ./common/tinc.nix
      ./common/users.nix
    ];

    time.timeZone = "America/New_York";
  };
  
  puck =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "10.99.0.3";

      imports = [
        ./modules/desktop
        ./modules/docker.nix
        ./systems/puck/desktop.nix
        ./systems/puck/hw.nix
        ./systems/puck/power.nix
        ./systems/puck/tinc.nix
        ./systems/puck/wireless.nix
      ];

      networking.hostName = "puck";
      system.stateVersion = "unstable";
    };

  rem =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "10.99.0.1";
      deployment.hasFastConnection = true;

      imports = [
        ./modules/cjdns.nix
        ./modules/desktop
        ./modules/docker.nix
        ./modules/kubernetes-common.nix
        ./modules/kubernetes-master.nix
        ./systems/rem/android.nix
        ./systems/rem/backups.nix
        ./systems/rem/bluray.nix
        ./systems/rem/coder.nix
        ./systems/rem/desktop.nix
        ./systems/rem/fusee-launcher.nix
        ./systems/rem/hw
        ./systems/rem/initrd-ssh.nix
        ./systems/rem/kindle.nix
        ./systems/rem/monitoring.nix
        ./systems/rem/network.nix
        ./systems/rem/nfs.nix
        ./systems/rem/nix.nix
        ./systems/rem/samba.nix
        ./systems/rem/scanner
        ./systems/rem/services.nix
        ./systems/rem/ssh-unlocker.nix
        ./systems/rem/tinc.nix
        ./systems/rem/vfio.nix
      ];

      networking.hostName = "rem";
      networking.hostId = "a23c4bef";

      # Options as Kubernetes entry node
      networking.firewall.allowedTCPPorts = [
        22 80 113 443 631
        # Mail ports
        25 143 587 993 4190
        # TLS turn ports
        5349 5350
        # Matrix
        8448
        # Tor
        9001
        # Minecraft
        25565 25566 25567 25568 25569 25570
        # Factorio
        34197 ];
      networking.firewall.allowedUDPPortRanges = [
        { from = 49152; to = 65535; } # TURN relay
      ];

      systemd.services.cups.enable = false; # don't conflict with docker cups

      # This value determines the NixOS release with which your system is to be
      # compatible, in order to avoid breaking some software such as database
      # servers. You should change this only after NixOS release notes say you
      # should.
      system.stateVersion = "unstable"; # Did you read the comment?
    };
  
  you =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "10.99.0.4";

      imports = [
        ./modules/desktop
        ./modules/docker.nix
        ./systems/you/desktop.nix
        ./systems/you/hw.nix
        ./systems/you/power.nix
        ./systems/you/tinc.nix
      ];

      networking.hostName = "you";
      system.stateVersion = "19.09";
    };
}
