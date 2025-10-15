{ config, pkgs, ... }:

{
  # PACOTES OTIMIZADOS - Shell rápido para RPi 3
  environment.systemPackages = with pkgs; [
    tmux
    vim
    curl
    git
    wget
    btop
    neovim
    lsd
    fzf
    gh
    kitty.terminfo
    gnumake
  ];

  # ZSH disponível mas não default (muito lento no RPi 3)
  programs.zsh.enable = true;
  programs.bash.enable = true;
  programs.nix-ld.enable = true;

  # BASH como default - 18x mais rápido que ZSH!
  users.defaultUserShell = pkgs.bash;
}
