# 🔧 NixOS Configuration for Raspberry Pi 3

> **A professional, modular NixOS configuration optimized for Raspberry Pi 3's limited resources (1GB RAM)**

[![NixOS](https://img.shields.io/badge/NixOS-23.11-blue.svg)](https://nixos.org/)
[![Raspberry Pi 3](https://img.shields.io/badge/Raspberry%20Pi-3-red.svg)](https://www.raspberrypi.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Key Features](#key-features)
- [Quick Start](#quick-start)
- [File Structure](#file-structure)
- [Module Details](#module-details)
- [Remote Builds Setup](#remote-builds-setup)
- [Challenges & Solutions](#challenges--solutions)
- [Performance](#performance)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)

---

## 🎯 Overview

This configuration was specifically designed to run NixOS on a **Raspberry Pi 3 (1GB RAM)**, overcoming the platform's resource limitations through intelligent architecture decisions and remote build capabilities.

### System Specs
- **Hardware**: Raspberry Pi 3 Model B
- **RAM**: 1GB (869MiB usable)
- **Architecture**: aarch64-linux
- **Network**: Ethernet only (WiFi disabled for stability)
- **NixOS Version**: Unstable (25.11pre876718)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Raspberry Pi 3 (1GB RAM)                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │            NixOS Configuration                        │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │  configuration.nix (Orchestrator)               │ │  │
│  │  │    ├─ hardware-configuration.nix               │ │  │
│  │  │    ├─ modules/packages.nix (11 packages)       │ │  │
│  │  │    ├─ modules/services.nix (SSH, firewall)     │ │  │
│  │  │    ├─ modules/users.nix (3 users)              │ │  │
│  │  │    ├─ modules/networking.nix (Ethernet)        │ │  │
│  │  │    └─ modules/dotfiles.nix (Auto-setup)        │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ SSH (Remote Builds)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Raspberry Pi 5 / Build Machine                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Handles heavy compilations                          │  │
│  │  ├─ 4 cores available for parallel builds            │  │
│  │  ├─ Returns compiled binaries to RPi 3               │  │
│  │  └─ Prevents system crashes from memory exhaustion   │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## ✨ Key Features

### 🎨 **Modular Design**
- **Separation of concerns**: Each aspect in its own module
- **Easy maintenance**: Update one module without touching others
- **Reusable**: Share modules across different machines

### 🚀 **Remote Build Support**
- **Offload compilations** to more powerful machine
- **Prevent crashes** from memory exhaustion
- **SSH-based** secure connection
- **Automatic failover** to local builds if remote unavailable

### 🐚 **Automatic Dotfiles Setup**
- **No Home Manager needed** (too heavy for RPi 3)
- **Auto-clones** from GitHub on system activation
- **Creates symlinks** for ZSH and Neovim configs
- **Works for all users** automatically

### 📦 **Essential Packages**
11 carefully selected packages for development:
```
tmux     │ Terminal multiplexer
vim      │ Classic editor
neovim   │ Modern vim
git      │ Version control
curl     │ HTTP client
wget     │ File downloader
btop     │ System monitor
lsd      │ Modern ls
fzf      │ Fuzzy finder
gh       │ GitHub CLI
kitty    │ Terminal emulator (terminfo)
```

### 💡 **Optimization for RPi 3**
- Documentation builds **disabled** (saves 100+ MB RAM)
- Binary cache **prioritized** (avoids compilation)
- WiFi **disabled** (ethernet more stable)
- Minimal **system services**

---

## 🚀 Quick Start

### Prerequisites
- Raspberry Pi 3 with NixOS installed
- Network connection (Ethernet recommended)
- (Optional) Another machine for remote builds

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/chalkan3/nixos-rpi3-config.git
   cd nixos-rpi3-config
   ```

2. **Backup existing configuration:**
   ```bash
   sudo cp -r /etc/nixos /etc/nixos.backup
   ```

3. **Copy configuration files:**
   ```bash
   sudo cp -r * /etc/nixos/
   ```

4. **Edit sensitive information:**
   ```bash
   sudo nano /etc/nixos/modules/users.nix       # Change passwords
   sudo nano /etc/nixos/configuration.nix       # Configure remote builds
   ```

5. **Apply configuration:**
   ```bash
   sudo nixos-rebuild switch
   ```

6. **Reboot:**
   ```bash
   sudo reboot
   ```

---

## 📁 File Structure

```
/etc/nixos/
├── configuration.nix              # Main orchestrator
├── hardware-configuration.nix     # Auto-detected hardware settings
└── modules/
    ├── packages.nix               # System packages (11 total)
    ├── services.nix               # SSH, firewall configuration
    ├── users.nix                  # User management (reusable function)
    ├── networking.nix             # Network configuration
    └── dotfiles.nix               # Automatic dotfiles setup
```

### Configuration Hierarchy

```
configuration.nix
  ├─► imports all modules
  ├─► sets boot configuration
  ├─► enables remote builds
  └─► disables documentation
       │
       ├─► packages.nix
       │     └─► Defines system packages & programs
       │
       ├─► services.nix
       │     └─► Configures SSH & firewall
       │
       ├─► users.nix
       │     └─► Creates users with newUser function
       │
       ├─► networking.nix
       │     └─► Ethernet-only configuration
       │
       └─► dotfiles.nix
             └─► Auto-setup via activation script
```

---

## 🔧 Module Details

### `configuration.nix` - Main Orchestrator

The central configuration file that:
- Imports all modules
- Configures boot loader
- Sets up remote builds
- Disables documentation (critical for RPi 3)

**Key sections:**
```nix
# Remote builds configuration
nix.buildMachines = [{
  hostName = "your-build-machine-ip";
  systems = [ "aarch64-linux" ];
  maxJobs = 4;
  sshUser = "your-username";
  sshKey = "/root/.ssh/id_ed25519";
}];
```

---

### `modules/packages.nix` - Package Management

Defines all system packages using Nix's elegant syntax:

```nix
environment.systemPackages = with pkgs; [
  tmux vim curl git wget
  btop neovim lsd fzf gh
  kitty.terminfo
];

programs.zsh.enable = true;
programs.nix-ld.enable = true;
users.defaultUserShell = pkgs.zsh;
```

**Features:**
- ✅ ZSH as default shell
- ✅ nix-ld for running dynamic binaries
- ✅ Minimal but complete development environment

---

### `modules/users.nix` - User Management

Elegant user creation with a reusable function:

```nix
let
  newUser = username: password: description: {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = password;
    description = description;
  };
in
{
  users.users = {
    nixos = newUser "nixos" "nixos" "Default User";
    chalkan3 = newUser "chalkan3" "change-me" "Your User";
  };
}
```

**Benefits:**
- 🎯 DRY principle (Don't Repeat Yourself)
- 🔧 Easy to add new users
- 🛡️ Consistent permissions

---

### `modules/networking.nix` - Network Configuration

Simple, stable ethernet-only setup:

```nix
networking.hostName = "lady-guica";
networking.useDHCP = false;
networking.interfaces.enu1u1u1.useDHCP = true;
```

**Why ethernet only?**
- ⚡ More stable than WiFi on RPi 3
- 🚫 WiFi drivers caused frequent hangs
- 🎯 Lower latency for remote builds

---

### `modules/services.nix` - Service Configuration

Minimal service configuration:

```nix
services.openssh = {
  enable = true;
  settings = {
    PermitRootLogin = "yes";
    PasswordAuthentication = true;
  };
};

networking.firewall.enable = false;
```

---

### `modules/dotfiles.nix` - **The Innovation!** 🌟

Automatic dotfiles setup **WITHOUT Home Manager**:

```nix
system.activationScripts.setupDotfiles = lib.stringAfter [ "users" ] ''
  setup_user_dotfiles() {
    local username=$1
    local home_dir=$2

    # Clone dotfiles if not exist
    if [ ! -d "$home_dir/dotfiles" ]; then
      sudo -u $username git clone https://github.com/chalkan3/dotfiles.git "$home_dir/dotfiles"
    fi

    # Create symlinks
    sudo -u $username bash -c "
      ln -sf $home_dir/dotfiles/.zsh .zsh
      ln -sf $home_dir/dotfiles/zshrc/.zshrc .zshrc
      ln -sf $home_dir/dotfiles/zshrc/.p10k.zsh .p10k.zsh
      ln -sf $home_dir/dotfiles/nvim .config/nvim
    "
  }

  # Apply to all normal users
  ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: user:
    lib.optionalString (user.isNormalUser)
      "setup_user_dotfiles ${name} ${user.home}"
  ) config.users.users)}
'';
```

**Why this approach?**
- 💚 **Lightweight**: No Home Manager overhead
- 🤖 **Automatic**: Runs on every `nixos-rebuild switch`
- 🔁 **Idempotent**: Safe to run multiple times
- 👥 **Universal**: Works for all users

**What it does:**
1. Clones your dotfiles repo (once)
2. Creates symlinks for ZSH configs
3. Links Neovim configuration
4. Runs for every normal user in the system

---

## 🛠️ Remote Builds Setup

### Why Remote Builds?

RPi 3 with 1GB RAM **cannot handle** compiling large packages:
- Kernel panics during builds
- System freezes for 10+ minutes
- Task kworker blocks (120+ seconds)

**Solution:** Offload compilation to a more powerful machine!

### Architecture

```
┌──────────────────┐                    ┌──────────────────┐
│   Raspberry Pi 3 │                    │  Build Machine   │
│                  │                    │  (RPi 5 / PC)    │
│  ┌────────────┐  │                    │                  │
│  │ nix-build  │  │  SSH Connection    │  ┌────────────┐  │
│  │            │──────────────────────────►│ nix-daemon │  │
│  └────────────┘  │                    │  │            │  │
│       │          │                    │  └─────┬──────┘  │
│       │ Wait     │                    │        │         │
│       │          │                    │        ▼         │
│       │          │                    │  ┌────────────┐  │
│       │          │                    │  │  Compile   │  │
│       │          │                    │  │  Package   │  │
│       │          │                    │  └─────┬──────┘  │
│       │          │                    │        │         │
│       │          │   Binary Package   │        │         │
│       ▼          │◄──────────────────────────  │         │
│  ┌────────────┐  │                    │  ┌─────▼──────┐  │
│  │  Install   │  │                    │  │   Send     │  │
│  └────────────┘  │                    │  └────────────┘  │
└──────────────────┘                    └──────────────────┘
```

### Setup Instructions

#### On the Build Machine (RPi 5 / PC):

1. **Add trusted user to Nix config:**
   ```bash
   sudo nano /etc/nix/nix.conf
   ```
   Add:
   ```
   trusted-users = root your-username
   experimental-features = nix-command flakes
   max-jobs = 4
   cores = 4
   ```

2. **Restart Nix daemon:**
   ```bash
   sudo systemctl restart nix-daemon
   ```

3. **Add Nix to PATH for SSH sessions:**
   ```bash
   nano ~/.zshenv  # or ~/.bashrc
   ```
   Add:
   ```bash
   if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
     . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   fi
   ```

#### On the Raspberry Pi 3:

1. **Generate SSH key:**
   ```bash
   sudo ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ""
   ```

2. **Copy key to build machine:**
   ```bash
   sudo ssh-copy-id -i /root/.ssh/id_ed25519.pub your-username@build-machine-ip
   ```

3. **Test connection:**
   ```bash
   sudo ssh your-username@build-machine-ip "nix-store --version"
   ```

4. **Update configuration.nix:**
   ```nix
   nix.buildMachines = [{
     hostName = "192.168.1.X";  # Your build machine IP
     systems = [ "aarch64-linux" ];
     maxJobs = 4;
     speedFactor = 2;
     supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
     sshUser = "your-username";
     sshKey = "/root/.ssh/id_ed25519";
   }];
   nix.distributedBuilds = true;
   ```

5. **Apply and test:**
   ```bash
   sudo nixos-rebuild switch

   # Test remote build
   nix-build -E 'with import <nixpkgs> {}; runCommand "test" {} "echo hello > $out"'
   # Should see: building '/nix/store/...' on 'ssh://user@host'
   ```

---

## 🎯 Challenges & Solutions

| Challenge | Problem | Solution |
|-----------|---------|----------|
| **Limited RAM** | System crashes during builds | Remote builds + disable documentation |
| **WiFi Instability** | Frequent disconnections and hangs | Ethernet-only configuration |
| **Home Manager** | Too heavy, caused system freeze | Custom activation script for dotfiles |
| **Build Times** | Hours for large packages | Binary cache + remote compilation |
| **User Management** | Repetitive user definitions | Reusable `newUser` function |

---

## 📊 Performance

### Memory Usage
```
Total: 869 MiB
Used:  201 MiB (23%)
Free:  584 MiB (67%)
```

### System Load
- **Idle**: 0.10 - 0.20
- **During SSH**: 0.30 - 0.50
- **Remote Build**: 0.60 - 0.90 (waiting for network)

### Boot Time
- **Cold boot**: ~45 seconds
- **Rebuild switch**: 10-30 seconds (depending on changes)

### Package Installation
- **From cache**: Instant (10-30s)
- **With remote builds**: Minutes (network + compilation)
- **Local compilation**: ⚠️ Not recommended (causes crashes)

---

## 🐛 Troubleshooting

### System hangs during rebuild

**Symptom:** `nixos-rebuild switch` hangs indefinitely

**Solution:**
1. Check if it's building documentation:
   ```bash
   ps aux | grep nix-build
   ```
2. Kill the build:
   ```bash
   sudo pkill -f nix-build
   ```
3. Ensure `documentation.enable = false;` in configuration.nix

---

### Remote builds not working

**Symptom:** Builds run locally instead of remote machine

**Checks:**
```bash
# Test SSH connection
sudo ssh your-username@build-machine "nix-store --version"

# Check nix-daemon on build machine
ssh build-machine "systemctl status nix-daemon"

# Verify PATH in SSH session
ssh build-machine "echo \$PATH" | grep nix
```

**Common fixes:**
- Add Nix to `.zshenv` / `.bashrc` on build machine
- Add user to `trusted-users` in `/etc/nix/nix.conf`
- Restart nix-daemon: `sudo systemctl restart nix-daemon`

---

### WiFi not working (by design!)

**Symptom:** `wlan0` interface is DOWN

**Explanation:** WiFi is intentionally disabled for stability.

**To re-enable:**
1. Edit `modules/networking.nix`
2. Add WiFi configuration
3. Expect potential instability

---

### Dotfiles not created

**Check:**
```bash
ls -la ~/.zshrc ~/.p10k.zsh ~/.config/nvim
```

**If missing:**
```bash
# Trigger activation script
sudo nixos-rebuild switch

# Check for errors
journalctl -xe | grep dotfiles
```

---

## 🎓 Advanced Tips

### Incremental Package Installation

If you're **still getting crashes**, install packages incrementally:

```bash
# Step 1: Essential tools
environment.systemPackages = with pkgs; [ vim git curl ];

# Apply
sudo nixos-rebuild switch

# Step 2: Add more
environment.systemPackages = with pkgs; [ vim git curl tmux zsh ];

# Apply again
sudo nixos-rebuild switch
```

---

### Optimize Binary Cache

Speed up installations by using Cachix:

```nix
nix.settings = {
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
};
```

---

### Monitor System Resources

Use `btop` (included in this config):

```bash
btop
```

Key metrics to watch:
- **Memory usage** (keep under 70%)
- **CPU load** (RPi 3 has 4 cores)
- **Network I/O** (during remote builds)

---

## 🤝 Contributing

Found a better way to optimize for RPi 3? Pull requests welcome!

1. Fork the repository
2. Create your feature branch
3. Test on actual hardware (important!)
4. Submit a pull request

---

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS on ARM](https://nixos.wiki/wiki/NixOS_on_ARM)
- [Distributed Builds](https://nixos.org/manual/nix/stable/advanced-topics/distributed-builds.html)

---

## 📜 License

MIT License - Feel free to use and modify!

---

## 🙏 Credits

Created with ❤️ by [chalkan3](https://github.com/chalkan3)

**Special thanks to:**
- NixOS community for amazing documentation
- Raspberry Pi Foundation for affordable ARM hardware
- Everyone who contributed to making NixOS work on ARM

---

## 📸 Screenshots

### System Information
```
     _____
    /  __ \
   | /  \/ ___  _ __ ___  _ __
   | |    / _ \| '_ ` _ \| '__|
   | \__/\ (_) | | | | | | |
    \____/\___/|_| |_| |_|_|

OS: NixOS 25.11 (Warbler) aarch64
Host: Raspberry Pi 3 Model B Rev 1.2
Kernel: 6.1.73
Uptime: 2 hours, 34 mins
Packages: 11 (user) + 1783 (system)
Shell: zsh 5.9
Memory: 201MiB / 869MiB (23%)
```

### Package List
```bash
$ which tmux vim nvim git curl wget btop lsd fzf gh
/run/current-system/sw/bin/tmux
/run/current-system/sw/bin/vim
/run/current-system/sw/bin/nvim
/run/current-system/sw/bin/git
/run/current-system/sw/bin/curl
/run/current-system/sw/bin/wget
/run/current-system/sw/bin/btop
/run/current-system/sw/bin/lsd
/run/current-system/sw/bin/fzf
/run/current-system/sw/bin/gh
```

---

<div align="center">

**⭐ Star this repo if it helped you!**

Made with 🔧 and ☕ on a Raspberry Pi 3

</div>
