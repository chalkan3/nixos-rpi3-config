{ config, pkgs, lib, ... }:

{
  # ===== OTIMIZAÇÕES AVANÇADAS PARA RASPBERRY PI 3 (1GB RAM) =====
  # Versão 2.0 - Otimizações Extremas

  # 1. ZRAM SWAP AUMENTADO (75% da RAM - mais agressivo)
  zramSwap = {
    enable = true;
    algorithm = "zstd";     # Compressão rápida e eficiente
    memoryPercent = 75;     # 75% da RAM (~650MB) = ~1.5GB swap comprimido efetivo!
    priority = 10;          # Prioridade mais alta que swap em arquivo
  };

  # 2. AJUSTES DE KERNEL AVANÇADOS
  boot.kernel.sysctl = {
    # === MEMÓRIA ===
    "vm.swappiness" = 5;                    # REDUZIDO: Praticamente nunca usa swap
    "vm.vfs_cache_pressure" = 50;           # Mantém: Boa performance de I/O
    "vm.min_free_kbytes" = 65536;           # NOVO: Garante 64MB sempre livre
    "vm.overcommit_memory" = 1;             # NOVO: Permite overcommit (útil com ZRAM)

    # === DIRTY PAGES (reduz writes no SD card) ===
    "vm.dirty_background_ratio" = 5;        # Mantém
    "vm.dirty_ratio" = 10;                  # Mantém
    "vm.dirty_expire_centisecs" = 3000;     # NOVO: Flush a cada 30s (padrão 30s)
    "vm.dirty_writeback_centisecs" = 1500;  # NOVO: Writeback a cada 15s

    # === NETWORKING (reduz latência) ===
    "net.ipv4.tcp_fin_timeout" = 30;
    "net.ipv4.tcp_keepalive_time" = 600;    # NOVO: Reduz keepalive overhead
    "net.ipv4.tcp_keepalive_intvl" = 60;
    "net.ipv4.tcp_keepalive_probes" = 3;
    "net.core.rmem_max" = 134217728;        # NOVO: 128MB receive buffer
    "net.core.wmem_max" = 134217728;        # NOVO: 128MB send buffer
    "net.ipv4.tcp_rmem" = "4096 87380 33554432";  # NOVO: Auto-tune receive
    "net.ipv4.tcp_wmem" = "4096 65536 33554432";  # NOVO: Auto-tune send

    # === SHARED MEMORY ===
    "kernel.shmmax" = 268435456;            # Mantém: 256MB

    # === KERNEL LOGGING (reduz overhead) ===
    "kernel.printk" = "3 3 3 3";            # NOVO: Reduz spam no console
  };

  # 3. TMPFS PARA /TMP (usa RAM ao invés de SD card)
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "rw" "nosuid" "nodev" "size=128M" ];  # 128MB limite
  };

  # 4. OTIMIZAÇÕES DE JOURNALD (limita uso de disco)
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

  # 5. GARBAGE COLLECTION MAIS AGRESSIVO
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";  # REDUZIDO: 30d → 14d
  };

  # Otimizações do Nix Store
  nix.settings = {
    auto-optimise-store = true;
    max-jobs = 1;
    cores = 2;
    min-free = 536870912;              # NOVO: Garante 512MB livre no /nix/store
    max-free = 2147483648;             # NOVO: Máximo 2GB livre (limpa se exceder)
  };

  # 6. DESABILITA SERVIÇOS DESNECESSÁRIOS (mais agressivo)
  systemd.services = {
    "man-db".enable = false;              # Mantém: man-db
    "systemd-journal-flush".enable = false;  # NOVO: Não persiste journal early boot
  };

  # Desabilita timers desnecessários
  systemd.timers = {
    "man-db".enable = false;              # Mantém
  };

  # 7. OTIMIZAÇÕES DE SYSTEMD
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "30s";       # Mantém
    DefaultTimeoutStopSec = "15s";        # Mantém
    DefaultMemoryAccounting = "yes";      # NOVO: Habilita memory accounting
    DefaultCPUAccounting = "yes";         # NOVO: Habilita CPU accounting
  };

  # 8. AJUSTES DE REDE TCP BBR + otimizações
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  boot.kernel.sysctl."net.core.default_qdisc" = "fq";
  boot.kernel.sysctl."net.ipv4.tcp_fastopen" = 3;  # NOVO: TCP Fast Open

  # 9. DESABILITA BLUETOOTH (não usado no RPi 3)
  hardware.bluetooth.enable = false;

  # 10. LIMITA COREDUMPS (economiza espaço)
  systemd.coredump.enable = false;

  # 11. OTIMIZA READLINE (menos memória no shell)
  environment.etc."inputrc".text = ''
    set bell-style none
    set completion-ignore-case on
    set show-all-if-ambiguous on
    set show-all-if-unmodified on
  '';
}
