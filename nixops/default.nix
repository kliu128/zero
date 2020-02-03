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
      ./common/dns.nix
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
  
  rem =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "10.99.0.1";
      deployment.hasFastConnection = true;

      imports = [
        ./modules/desktop
        ./modules/docker.nix
        ./modules/kubernetes-common.nix
        ./modules/kubernetes-master.nix
        ./systems/rem/android.nix
        ./systems/rem/backups.nix
        ./systems/rem/bluray.nix
        ./systems/rem/ddns.nix
        ./systems/rem/desktop.nix
        ./systems/rem/fusee-launcher.nix
        ./systems/rem/hw
        ./systems/rem/initrd-ssh.nix
        ./systems/rem/monitoring.nix
        ./systems/rem/network.nix
        ./systems/rem/nfs.nix
        ./systems/rem/nix.nix
        ./systems/rem/wireguard.nix
        ./systems/rem/pbx.nix
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
        25 143 587 993 4190 # Sieve
        # TLS turn ports
        5349 5350
        # Matrix
        8448
        # Tor
        32972 32973
        # Factorio
        34197
        # Scintillating mail server ports
        2025 20143 20465 20587 20993
        # Storj
        28967 ];
      networking.firewall.allowedUDPPortRanges = [
        { from = 49152; to = 65535; } # TURN relay
      ];

      systemd.services.cups.enable = false; # don't conflict with docker cups

      # This value determines the NixOS release with which your system is to be
      # compatible, in order to avoid breaking some software such as database
      # servers. You should change this only after NixOS release notes say you
      # should.
      system.stateVersion = "19.09"; # Did you read the comment?
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
      networking.hostId = "b9123efc";

      system.stateVersion = "19.09";
    };

  karmaxer =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "192.168.1.3";

      imports = [
        ./modules/docker.nix
        ./modules/kubernetes-common.nix
        ./modules/kubernetes-node.nix
        ./systems/karmaxer/hw.nix
        ./systems/karmaxer/services.nix
        ./systems/karmaxer/tinc.nix
      ];

      networking.hostName = "karmaxer";

      system.stateVersion = "19.09";

      networking.firewall.allowedTCPPorts = [
        # Minecraft
        25565 25566 25567 25568 25569 25570
      ];
    };
}
