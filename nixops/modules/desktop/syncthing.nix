{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "kevin";
    group = "users";
    dataDir = "/home/kevin/.config/syncthing";
    openDefaultPorts = true;
    declarative = {
      devices = {
        rem = {
          id = "3CTE5PM-OBKFFKV-MCGWKWD-ORXIF7W-C3NL6DD-JWRISEB-KTZ2WB7-PKAFKQZ";
          addresses = [ "dynamic" "tcp://10.99.0.1:22000" ];
        };
        puck = {
          id = "EFZWFF6-26DCOQY-APGKNVJ-D53BNMG-MNQPTD6-ARQIGQ7-MNI3DCK-TOBKAQZ";
          addresses = [ "dynamic" "tcp://10.99.0.3:22000" ];
        };
        momo = {
          id = "RPLTW4L-XMQPMH3-U22OP4B-252EHUL-QJQB4RE-FQDRZNY-7VV6MAD-NOY5GAT";
        };
        you = {
          id = "STZY4Y5-5MM6VLA-Q5B4QBY-G75FJSC-35DY67V-EJZL5FV-SANZUXT-NDGBRAL";
          addresses = [ "dynamic" "tcp://10.99.0.4:22000" ];
        };
      };
      folders = {
        "/home/kevin/Books" = {
          id = "viyof-qyadp";
          label = "Books";
          devices = [ "rem" "puck" "momo" "you" ];
        };
        "/home/kevin/Personal Documents" = {
          id = "skrpu-wk5qc";
          label = "Documents";
          devices = [ "rem" "puck" "momo" "you" ];
        };
        "/home/kevin/Personal Documents/Org Mode" = {
          id = "org-mode";
          label = "Org Mode";
          devices = [ "rem" "puck" "momo" "you" ];
        };
        "/mnt/storage/Kevin/Personal/Media/SYNCED OnePlus 6t Current Photos" = {
          id = "oneplus_a6010_81rt-photos";
          label = "Camera";
          devices = [ "rem" "momo" ];
        };
      };
    };
  };
}
