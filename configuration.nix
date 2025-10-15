{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/users.nix
    ./modules/networking.nix
    ./modules/dotfiles.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Hardware
  hardware.enableRedistributableFirmware = true;

  # DESABILITAR DOCUMENTAÇÃO - muito pesado para RPi 3
  documentation.enable = false;
  documentation.nixos.enable = false;

  # Remote builds usando RPi 5 (ou outra máquina mais potente)
  # IMPORTANTE: Configure sua máquina remota antes de usar
  nix.buildMachines = [{
    hostName = "your-build-machine-ip";  # Ex: "192.168.1.X"
    systems = [ "aarch64-linux" ];
    maxJobs = 4;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    sshUser = "your-username";  # Usuário com acesso à máquina remota
    sshKey = "/root/.ssh/id_ed25519";  # Chave SSH para autenticação
  }];

  nix.distributedBuilds = true;

  system.stateVersion = "23.11";
}
