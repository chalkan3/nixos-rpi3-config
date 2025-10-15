{ config, pkgs, ... }:

{
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

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
