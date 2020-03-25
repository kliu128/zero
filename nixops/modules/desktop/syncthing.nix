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
          id = "LD5CZZW-C4FJKPW-VPFXK4C-2ZGOGVL-YUBBNT5-OOX65GT-3CHHDSL-RGWQYQS";
          addresses = [ "dynamic" "tcp://10.99.0.1:22000" ];
        };
        momo = {
          id = "RPLTW4L-XMQPMH3-U22OP4B-252EHUL-QJQB4RE-FQDRZNY-7VV6MAD-NOY5GAT";
        };
        you = {
          id = "EZM3INK-XK464QB-HGVD7A6-BWHFHWG-BLXXH7V-HQXOD6J-CZHOTRU-GCDXOQH";
        };
      };
      folders = {
        "/home/kevin/Books" = {
          id = "viyof-qyadp";
          label = "Books";
          devices = [ "rem" "momo" "you" ];
        };
        "/home/kevin/Personal Documents" = {
          id = "skrpu-wk5qc";
          label = "Documents";
          devices = [ "rem" "you" ];
        };
        "/home/kevin/Personal Documents/Org Mode" = {
          id = "org-mode";
          label = "Org Mode";
          devices = [ "rem" "momo" "you" ];
        };
        "/mnt/storage/Kevin/Personal/Media/SYNCED OnePlus 6t Current Photos" = {
          id = "oneplus_a6010_81rt-photos";
          label = "Camera";
          devices = [ "rem" ];
        };
      };
    };
  };
}
