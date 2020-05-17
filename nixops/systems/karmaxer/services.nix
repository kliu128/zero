{ config, lib, pkgs, ... }:

{
  services.gitlab-runner = {
    enable = true;
    configFile = pkgs.writeText "config" ''
      concurrent = 2

      [[runners]]
      executor = "docker"
      name = "docker-runner"
      token = "CWrnm3xesq_U8NGFWxjd"
      url = "https://gitlab.scintillating.us/"

      [runners.docker]
      disable_cache = false
      image = "ruby:2.1"
      network_mode = "host"
      privileged = true
      tls_verify = false
      volumes = ["/dev/shm:/dev/shm"]
    '';
  };

  virtualisation.libvirtd.enable = true;
  # Allow kevin to manage libvirt
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];
}
