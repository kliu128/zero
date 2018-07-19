{ config, lib, pkgs, ... }:

{
  # ZSH
  users.extraUsers.kevin.shell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    theme = "agnoster";
    plugins = [ "tmux" "git" ];
  };
  programs.zsh.interactiveShellInit = ''
    # Colorized man
    man() {
        LESS_TERMCAP_md=$'\e[01;31m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[01;44;33m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[01;32m' \
        command man "$@"
    }

    export PATH=$HOME/.cargo/bin:$PATH:$HOME/bin:$HOME/Android/Sdk/ndk-bundle:$HOME/Android/Sdk/platform-tools:$HOME/.npm-global/bin:$HOME/.local/bin:$HOME/.local/var/npm/bin
    if [[ "$DISPLAY" ]]; then
      # Use graphical emacs
      export EDITOR="emacsclient --socket-name=/tmp/emacs1000/server "
      alias emacs="$EDITOR "
    else
      # Just use vim:tm: without graphical environment
      export EDITOR="vim "
    fi
    
    alias k=kubectl

    # Set GPG TTY (for SSH sessions, etc.)
    export GPG_TTY=$(tty)

    # Refresh gpg-agent tty in case user switches into an X session
    gpg-connect-agent updatestartuptty /bye >/dev/null

    # MOTD
    print -P "Welcome to \e[1m\e[36m$(cat /etc/hostname)%F{reset_color}\e[0m\!"
    print -P "   Kernel: $(uname -r) ($(uname -v))%F{reset_color}"
    # show system status
    systemctl status | head -n 5 | tail -n 4

    echo ""

    # fun cowsay
    fortune | cowsay | lolcat

    echo ""
  '';
}
