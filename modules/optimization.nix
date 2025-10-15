{ config, pkgs, lib, ... }:

{
  # ===== OTIMIZAÇÕES PARA MÁXIMA RESPONSIVIDADE - RPi 3 =====
  # Versão 2.2 - Foco em VELOCIDADE INTERATIVA

  # 1. ZRAM MODERADO (50% - deixa mais RAM livre)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;     # 50% = ~434MB (mais RAM disponível!)
    priority = 10;
  };

  # 2. KERNEL - Favorece RESPONSIVIDADE
  boot.kernel.sysctl = {
    # MEMÓRIA - otimizado para interatividade
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.min_free_kbytes" = 16384;      # 16MB (menos reserva)
    "vm.overcommit_memory" = 1;

    # DIRTY PAGES - menos agressivo
    "vm.dirty_background_ratio" = 10;   # AUMENTADO para menos writes
    "vm.dirty_ratio" = 20;              # AUMENTADO
    "vm.dirty_expire_centisecs" = 3000;
    "vm.dirty_writeback_centisecs" = 500;  # Mais frequente

    # NETWORKING - valores padrão (menos overhead)
    "net.ipv4.tcp_fin_timeout" = 30;
    "net.ipv4.tcp_fastopen" = 3;

    # SHARED MEMORY
    "kernel.shmmax" = 268435456;
  };

  # 3. /TMP PEQUENO (32MB é suficiente)
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "rw" "nosuid" "nodev" "size=32M" ];
  };

  # 4. JOURNALD LIMITADO
  services.journald.extraConfig = ''
    SystemMaxUse=50M
    RuntimeMaxUse=50M
    SystemMaxFileSize=10M
    MaxRetentionSec=2week
    MaxFileSec=1day
    ForwardToSyslog=no
    ForwardToKMsg=no
    ForwardToConsole=no
  '';

  # 5. NIX GC
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 21d";
  };

  nix.settings = {
    auto-optimise-store = true;
    max-jobs = 1;
    cores = 2;
    min-free = 268435456;   # 256MB
    max-free = 2147483648;  # 2GB
  };

  # 6. DESABILITA SERVIÇOS PESADOS
  systemd.services = {
    "man-db".enable = false;
    "systemd-journal-flush".enable = false;
    "systemd-oomd".enable = false;           # NOVO: Desabilita OOM killer
  };

  systemd.timers = {
    "man-db".enable = false;
  };

  # 7. SYSTEMD - SEM accounting (overhead!)
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "30s";
    DefaultTimeoutStopSec = "15s";
    # REMOVIDO: DefaultMemoryAccounting = "yes";  # Causa overhead!
    # REMOVIDO: DefaultCPUAccounting = "yes";     # Causa overhead!
  };

  # 8. TCP BBR
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  boot.kernel.sysctl."net.core.default_qdisc" = "fq";

  # 9. BLUETOOTH OFF
  hardware.bluetooth.enable = false;

  # 10. COREDUMPS OFF
  systemd.coredump.enable = false;

  # 11. READLINE
  environment.etc."inputrc".text = ''
    set bell-style none
    set completion-ignore-case on
    set show-all-if-ambiguous on
    set show-all-if-unmodified on
  '';
}
