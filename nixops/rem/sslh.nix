{ config, lib, pkgs, ... }:

{
  services.sslh = {
    enable = true;
    port = 443;
    appendConfig = ''
      protocols: (
        { name: "ssh"; service: "ssh"; host: "localhost"; port: "843"; probe: "builtin"; },
        { name: "ssl"; host: "localhost"; port: "8443"; probe: "builtin"; }
      ); 
    '';
  };
}
