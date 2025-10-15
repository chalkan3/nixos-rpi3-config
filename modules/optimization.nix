{ config, pkgs, lib, ... }:

{
  # ===== OTIMIZAÇÕES PARA RASPBERRY PI 3 (1GB RAM) =====

  # 1. ZRAM SWAP (usa compressão na RAM - muito mais rápido que SD card)
  zramSwap = {
    enable = true;
    algorithm = "zstd";  # Compressão rápida e eficiente
    memoryPercent = 50;  # Usa 50% da RAM para swap comprimido (efetivo ~1GB extra)
  };

  # 2. AJUSTES DE KERNEL PARA BAIXO USO DE MEMÓRIA
  boot.kernel.sysctl = {
    # Reduz swappiness (só usa swap quando realmente necessário)
    "vm.swappiness" = 10;

    # Melhora performance de I/O
    "vm.vfs_cache_pressure" = 50;

    # Otimiza dirty pages (reduz writes no SD card)
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;

    # Reduz tempo de espera para conexões TCP (mais responsivo)
    "net.ipv4.tcp_fin_timeout" = 30;

    # Otimiza memória compartilhada
    "kernel.shmmax" = 268435456;  # 256MB
  };

  # 3. GARBAGE COLLECTION AUTOMÁTICO DO NIX
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Otimiza store do Nix (deduplica arquivos)
  nix.settings = {
    auto-optimise-store = true;
    # Limita builds paralelos (poupa memória)
    max-jobs = 1;
    cores = 2;
  };

  # 4. DESABILITA SERVIÇOS DESNECESSÁRIOS
  systemd.services = {
    # Desabilita timer de man-db (pesado e desnecessário)
    "man-db".enable = false;
  };

  # 5. OTIMIZAÇÕES DE SYSTEMD (sintaxe correta para NixOS unstable)
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "30s";
    DefaultTimeoutStopSec = "15s";
  };

  # 6. AJUSTES DE REDE (reduz latência)
  boot.kernelModules = [ "tcp_bbr" ];  # Congestion control moderno
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  boot.kernel.sysctl."net.core.default_qdisc" = "fq";
}
