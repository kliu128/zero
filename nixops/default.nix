# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

let credentials = {
  project = "scintillating-204712";
  serviceAccount = "159794995113-compute@developer.gserviceaccount.com";
  accessKey = toString ./secrets/gce-access-key.json;
}; in {
  network = {
    description = "Re:Zero Production™ Cluster";
    enableRollback = true;
  };
  
  defaults = {
    networking.domain = "potatofrom.space";
    time.timeZone = "America/New_York";
  };

  otto =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "otto.lan";
      deployment.hasFastConnection = true;

      imports = [
        ./common/earlyoom.nix
        ./common/firewall.nix
        ./common/kernel.nix
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

  rem =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "rem.lan";
      deployment.hasFastConnection = true;

      imports = [
        ./common/earlyoom.nix
        ./common/firewall.nix
        ./common/kernel.nix
        ./common/ssh.nix
        ./common/time.nix
        ./common/users.nix
        ./modules/docker.nix
        ./modules/kdeconnect.nix
        ./modules/kubernetes-common.nix
        ./modules/kubernetes-master.nix
        ./rem/backups.nix
        ./rem/desktop.nix
        ./rem/fusee-launcher.nix
        ./rem/hw.nix
        ./rem/ipv6-tunnel.nix
        ./rem/kindle.nix
        ./rem/nfs.nix
        ./rem/nix.nix
        ./rem/samba.nix
        ./rem/vfio.nix
        ./rem/zsh.nix
      ];

      networking.hostName = "rem";

      # Options as Kubernetes entry node
      networking.firewall.allowedTCPPorts = [
        22 25 80 143 443 587 993 8448 9001 9030 25565 ];

      # This value determines the NixOS release with which your system is to be
      # compatible, in order to avoid breaking some software such as database
      # servers. You should change this only after NixOS release notes say you
      # should.
      system.nixos.stateVersion = "unstable"; # Did you read the comment?
    };

  resources.gceStaticIPs.puck-ip = credentials // {
    ipAddress = "35.227.45.146";
    region = "us-east1";
  };
  
  puck =
    { config, pkgs, lib, resources, ... }:
    {
      # Reduced set of imports
      imports = [
        ./common/earlyoom.nix
        ./common/firewall.nix
        ./common/kernel.nix
        ./common/time.nix
      ];
      networking.firewall.allowedTCPPorts = [ 22 ];
      
      deployment.targetEnv = "gce";
      deployment.gce = credentials // {
        instanceType = "f1-micro";
        rootDiskSize = 25; # GB
        region = "us-east1-b";
        ipAddress = resources.gceStaticIPs.puck-ip;
      };

      # This value determines the NixOS release with which your system is to be
      # compatible, in order to avoid breaking some software such as database
      # servers. You should change this only after NixOS release notes say you
      # should.
      system.nixos.stateVersion = "unstable"; # Did you read the comment?
    };
}
