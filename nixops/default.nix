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
      ./common/nix.nix
      ./common/security.nix
      ./common/ssh.nix
      ./common/time.nix
      ./common/tinc.nix
      ./common/users.nix
    ];

    time.timeZone = "America/New_York";
  };

  otto =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "10.99.0.2";
      deployment.hasFastConnection = true;

      imports = [
        # ./modules/docker.nix
        # ./modules/boinc.nix
        # ./modules/kubernetes-common.nix
        # ./modules/kubernetes-node.nix
        ./modules/lizardfs-mnt.nix
        ./otto/hw.nix
        ./otto/initrd-ssh.nix
        ./otto/lizardfs.nix
        # ./otto/netconsole-receiver.nix
        ./otto/reverse-proxy.nix
        ./otto/tinc.nix
      ];

      networking.hostName = "otto";

      system.stateVersion = "unstable";
    };
  
  puck =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "10.99.0.3";

      imports = [
        ./modules/desktop
        ./modules/docker.nix
        ./puck/desktop.nix
        ./puck/hw.nix
        ./puck/power.nix
        ./puck/tinc.nix
        ./puck/wireless.nix
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
        ./modules/lizardfs-mnt.nix
        ./rem/android.nix
        ./rem/backups.nix
        ./rem/bluray.nix
        # ./rem/boinc.nix
        ./rem/desktop.nix
        ./rem/fusee-launcher.nix
        ./rem/hw
        ./rem/initrd-ssh.nix
        ./rem/kindle.nix
        ./rem/lizardfs.nix
        ./rem/monitoring.nix
        ./rem/netconsole-client.nix
        ./rem/network.nix
        ./rem/nfs.nix
        ./rem/nix.nix
        ./rem/printmon.nix
        ./rem/samba.nix
        ./rem/scanner
        ./rem/services.nix
        ./rem/ssh-unlocker.nix
        ./rem/tinc.nix
        ./rem/unbound.nix
        ./rem/vfio.nix
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
        25565 25566 25567 25568 25569 25570 ];
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
}
