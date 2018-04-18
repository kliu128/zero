{ config, lib, pkgs, ... }:

{
  # ZSH
  users.extraUsers.kevin.shell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    theme = "blinks";
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
    export EDITOR="emacsclient "
    alias emacs="$EDITOR "

    print-to-the-freaking-color-printer() {
        gs -q -dBATCH -dSAFER -dQUIET -dNOPAUSE -sPAPERSIZE=a4 -r600x600 -sDEVICE=pamcmyk32 -sOutputFile=- "$1" | foo2hbpl1 | nc dell3d0572.lan 9100
    }

    # MOTD
    print -P "Welcome to \e[1m\e[36m$(hostnamectl --pretty) (Arch Linux)%F{reset_color}\e[0m\!"
    print -P "   Kernel: $(uname -r) ($(uname -v))%F{reset_color}"
    # show system status
    systemctl status | head -n 5 | tail -n 4

    echo ""

    # fun cowsay
    fortune | cowsay | lolcat

    echo ""
  '';
}