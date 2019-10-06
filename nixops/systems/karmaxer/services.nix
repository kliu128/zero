{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  services.gitlab-runner = {
    enable = true;
    configOptions = {
      concurrent = 10;
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
            volumes = ["/certs/client" "/cache" "/dev/shm:/dev/shm"];
            shm_size = 0;
          };
        }
      ];
    };
  };
}