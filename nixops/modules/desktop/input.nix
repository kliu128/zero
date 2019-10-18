{ config, lib, pkgs, ... }:

{
  users.extraUsers.kevin.extraGroups = [ "input" ];
  services.xserver = {
    xkbOptions = "terminate:ctrl_alt_bksp";
    xkbVariant = "altgr-intl";
  };
  i18n.inputMethod = {
    enabled = "ibus";
    ibus = {
      engines = with pkgs.ibus-engines; [ libpinyin ];
    };
  };
}
