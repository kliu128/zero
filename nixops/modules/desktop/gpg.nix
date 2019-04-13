{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ gnupg ];
  home-manager.users.kevin = {
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };
    programs.zsh.initExtra = ''
      # Set GPG TTY (for SSH sessions, etc.)
      export GPG_TTY=$(tty)

      # Refresh gpg-agent tty in case user switches into an X session
      gpg-connect-agent updatestartuptty /bye >/dev/null
    '';
  };
}
