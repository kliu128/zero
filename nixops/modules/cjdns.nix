{ config, lib, pkgs, ... }:

{
  services.cjdns = {
    enable = true;
    UDPInterface = {
      bind = "0.0.0.0:43211";
      connectTo = {
        "192.34.85.155:2359" = {
          hostname = "igel-massachusetts.usa.k";
          password = "alfa-charlie-alfa-bravo";
          publicKey = "rdxg1nzvmjdj4fyguqydmnl659p7m3x26r6un4ql966q4xt988j0.k";
        };
        "107.170.57.34:63472" = {
          hostname = "cord.ventricle.us";
          password = "ppm6j89mgvss7uvtntcd9scy6166mwb";
          publicKey = "1xkf13m9r9h502yuffsq1cg13s5648bpxrtf2c3xcq1mlj893s90.k";
        };
      };
    };
  };
}