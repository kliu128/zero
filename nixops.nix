# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  network = {
    description = "Re:Zero Production™ Cluster";
    enableRollback = true;
  };
  
  defaults.imports = [
    ./common/firewall.nix
    ./common/ssh.nix
    ./common/users.nix
  ];

  otto =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "otto.lan";
      deployment.hasFastConnection = true;

      imports = [
        ./otto/hw.nix
      ];
    };

  rem =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "rem.lan";
      deployment.hasFastConnection = true;

      imports = [
        ./rem/backups.nix
        ./rem/desktop.nix
        ./rem/docker.nix
        ./rem/hw.nix
        ./rem/kindle.nix
        ./rem/nfs.nix
        ./rem/nix.nix
        ./rem/vfio.nix
        ./rem/zsh.nix
        ./common/kubernetes.nix
      ];

      networking.hostName = "rem"; # Define your hostname
      networking.domain = "potatofrom.space";
      
      # Set your time zone.
      time.timeZone = "America/New_York";

      # This value determines the NixOS release with which your system is to be
      # compatible, in order to avoid breaking some software such as database
      # servers. You should change this only after NixOS release notes say you
      # should.
      system.stateVersion = "unstable"; # Did you read the comment?
    };
}
