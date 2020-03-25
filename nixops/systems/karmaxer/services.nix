{ config, lib, pkgs, ... }:

{
  services.gitlab-runner = {
    enable = true;
    configOptions = {
      concurrent = 2;
      runners = [
        {
          name = "docker-runner";
          url = "https://gitlab.scintillating.us/";
          token = "CWrnm3xesq_U8NGFWxjd";
          executor = "docker";
          docker = {
            tls_verify = false;
            image = "ruby:2.1";
            privileged = true;
            disable_cache = false;
            network_mode = "host";
            volumes = [
              # Prevent cypress hangs
              # see https://github.com/cypress-io/cypress/issues/350
              "/dev/shm:/dev/shm"
            ];
          };
        }
      ];
    };
  };

  virtualisation.libvirtd.enable = true;
  # Allow kevin to manage libvirt
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];
}
