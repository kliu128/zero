{ config, lib, pkgs, ... }:
{
  # U2F
  hardware.u2f.enable = true;
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    # U2F
    yubikey-personalization-gui yubikey-manager
  ];
  services.udev.packages = [ pkgs.yubikey-personalization-gui ];

  services.udev.extraRules = ''
    ACTION=="add", ENV{ID_BUS}=="usb", ENV{ID_MODEL_ID}=="0407", ENV{ID_VENDOR_ID}=="1050", RUN+="${pkgs.bash}/bin/bash /etc/wake.sh"
    ACTION=="remove", ENV{ID_BUS}=="usb", ENV{ID_MODEL_ID}=="0407", ENV{ID_VENDOR_ID}=="1050", RUN+="${pkgs.bash}/bin/bash /etc/lock.sh"
  '';

  services.actkbd = {
    enable = true;
    bindings = [
      # Shift key - create /tmp/inhibit_yubikey_lock on press, delete on
      # release
      { keys = [ 42 ];
        events = [ "key" ];
        command = "${pkgs.coreutils}/bin/touch /tmp/inhibit_yubikey_lock"; }
      { keys = [ 42 ];
        events = [ "rel" ];
        command = "${pkgs.coreutils}/bin/rm /tmp/inhibit_yubikey_lock"; }
    ];
  };
  systemd.tmpfiles.rules = [
    # Remove inhibit marker on boot to avoid stuck conditions
    "r! /tmp/inhibit_yubikey_lock"
  ];

  environment.etc."wake.sh".source = pkgs.writeScript "wake" ''
    #!${pkgs.stdenv.shell}
    export PATH=${lib.makeBinPath [ pkgs.xorg.xset ]}
    XAUTHORITY=/tmp/xauth-1000-_0 xset -display ":0" dpms force on
  '';

  environment.etc."lock.sh".source = pkgs.writeScript "lock" ''
    #!${pkgs.stdenv.shell}
    export PATH=${lib.makeBinPath [ pkgs.systemd pkgs.xorg.xset ]}

    if [ ! -f /tmp/inhibit_yubikey_lock ]; then
      loginctl lock-sessions
      XAUTHORITY=/tmp/xauth-1000-_0 xset -display ":0" dpms force off
    fi
  '';

  security.pam.services.login.u2fAuth = true;
  security.pam.services.sddm.u2fAuth = true;
  security.pam.services.kde.u2fAuth = true;
  security.pam.u2f = {
    control = "required";
    authFile = ./u2f-mappings;
  };
  security.pam.services.sudo.text = ''
    account required pam_unix.so
    auth sufficient ${pkgs.pam_u2f}/lib/security/pam_u2f.so authfile=${./u2f-mappings}
    auth sufficient pam_unix.so likeauth try_first_pass
    auth required pam_deny.so
    password sufficient pam_unix.so nullok sha512
    session required pam_unix.so
  '';
}