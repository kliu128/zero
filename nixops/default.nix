# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

let credentials = {
  project = "zero-cluster";
  serviceAccount = "nixops@zero-cluster.iam.gserviceaccount.com";
  accessKey = toString ./secrets/gce-access-key.json;
}; in {
  network = {
    description = "Re:Zero Production™ Cluster";
    enableRollback = true;
  };
  
  defaults = {
    imports = [
    ];

    networking.domain = "potatofrom.space";
    time.timeZone = "America/New_York";
  };

  otto =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "192.168.1.11";
      deployment.hasFastConnection = true;

      imports = [
        ./common/dns.nix
        ./common/earlyoom.nix
        ./common/firewall.nix
        ./common/kernel.nix
        ./common/nix.nix
        ./common/ssh.nix
        ./common/time.nix
        ./common/users.nix
        ./modules/docker.nix
        ./modules/kubernetes-common.nix
        ./modules/kubernetes-node.nix
        ./otto/hw.nix
      ];

      networking.hostName = "otto";

      system.nixos.stateVersion = "unstable";
    };
  
  puck =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = (import ./wireguard.nix).ips.puck;

      imports = [
        ./common/dns.nix
        ./common/earlyoom.nix
        ./common/firewall.nix
        ./common/kernel.nix
        ./common/nix.nix
        ./common/ssh.nix
        ./common/time.nix
        ./common/users.nix
        ./modules/desktop.nix
        ./puck/desktop.nix
        ./puck/hw.nix
        ./puck/nfs-filesystems.nix
        ./puck/wireguard.nix
        ./puck/wireless.nix
      ];

      networking.hostName = "puck";
      system.nixos.stateVersion = "unstable";
    };

  rem =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "192.168.1.5";
      deployment.hasFastConnection = true;

      imports = [
        ./common/dns.nix
        ./common/earlyoom.nix
        ./common/firewall.nix
        ./common/kernel.nix
        ./common/nix.nix
        ./common/ssh.nix
        ./common/time.nix
        ./common/users.nix
        ./modules/desktop.nix
        ./modules/docker.nix
        ./modules/kdeconnect.nix
        ./modules/kubernetes-common.nix
        ./modules/kubernetes-master.nix
        ./modules/toxvpn.nix
        ./rem/backups.nix
        ./rem/desktop.nix
        ./rem/fusee-launcher.nix
        ./rem/hw.nix
        ./rem/ipv6-tunnel.nix
        ./rem/kindle.nix
        ./rem/locate.nix
        ./rem/monitoring.nix
        ./rem/nfs.nix
        ./rem/nix.nix
        ./rem/samba.nix
        ./rem/services.nix
        ./rem/unbound.nix
        ./rem/vfio.nix
        ./rem/wireguard.nix
      ];

      networking.hostName = "rem";

      # Options as Kubernetes entry node
      networking.firewall.allowedTCPPorts = [
        22 25 80 143 443 587 631 993 8448 9001 9030 25565 ];

      systemd.services.cups.enable = false; # don't conflict with docker cups
      
      # ToxVPN ip
      services.toxvpn.localip = "10.123.123.1";

      # This value determines the NixOS release with which your system is to be
      # compatible, in order to avoid breaking some software such as database
      # servers. You should change this only after NixOS release notes say you
      # should.
      system.nixos.stateVersion = "unstable"; # Did you read the comment?
    };

  resources.gceStaticIPs.beatrice-ip = credentials // {
    ipAddress = "35.227.53.55";
    region = "us-east1";
  };
  
  beatrice =
    { config, pkgs, lib, resources, ... }:
    {
      # Reduced set of imports
      imports = [
        ./common/dns.nix
        ./common/earlyoom.nix
        ./common/firewall.nix
        ./common/kernel.nix
        ./common/time.nix
      ];
      networking.firewall.allowedTCPPorts = [ 22 ];
      
      deployment.targetEnv = "gce";
      deployment.gce = credentials // {
        instanceType = "f1-micro";
        rootDiskSize = 20; # GB
        region = "us-east1-b";
        ipAddress = resources.gceStaticIPs.beatrice-ip;
      };

      # This value determines the NixOS release with which your system is to be
      # compatible, in order to avoid breaking some software such as database
      # servers. You should change this only after NixOS release notes say you
      # should.
      system.nixos.stateVersion = "unstable"; # Did you read the comment?
    };
}
