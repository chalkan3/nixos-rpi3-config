{ config, pkgs, ... }:

{
  # TODOS OS PACOTES DE UMA VEZ - Testando remote builds\!
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
  ];

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
