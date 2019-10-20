{ config, lib, pkgs, ... }:

{
  services.gitlab-runner = {
    enable = true;
    configOptions = {
      concurrent = 3;
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
            volumes = ["/certs/client" "/builds:/dev/shm/gitlab-runner" "/cache" "/dev/shm:/dev/shm"];
            shm_size = 0;
            network_mode = "host";
          };
        }
      ];
    };
  };
}
