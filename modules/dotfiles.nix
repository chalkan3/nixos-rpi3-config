{ config, pkgs, lib, ... }:

{
  system.activationScripts.setupDotfiles = lib.stringAfter [ "users" ] ''
    # Função para configurar dotfiles para um usuário
    setup_user_dotfiles() {
      local username=$1
      local home_dir=$2

      echo "Setting up dotfiles for $username..."

      # Clone dotfiles se não existir
      if [ ! -d "$home_dir/dotfiles" ]; then
        echo "  Cloning dotfiles repository..."
        ${pkgs.sudo}/bin/sudo -u $username ${pkgs.git}/bin/git clone https://github.com/chalkan3/dotfiles.git "$home_dir/dotfiles" 2>/dev/null || true
      fi

      # Verifica se o clone foi bem sucedido
      if [ -d "$home_dir/dotfiles" ]; then
        echo "  Creating symlinks..."

        # Remove configs antigas e cria symlinks
        ${pkgs.sudo}/bin/sudo -u $username ${pkgs.bash}/bin/bash -c "
          cd $home_dir

          # Remove links/arquivos antigos
          rm -f .zshrc .p10k.zsh
          rm -rf .zsh

          # Cria symlinks para ZSH
          ln -sf $home_dir/dotfiles/.zsh .zsh
          ln -sf $home_dir/dotfiles/zshrc/.zshrc .zshrc
          ln -sf $home_dir/dotfiles/zshrc/.p10k.zsh .p10k.zsh

          # Cria symlink para Neovim
          mkdir -p .config
          rm -rf .config/nvim
          ln -sf $home_dir/dotfiles/nvim .config/nvim
        "

        echo "  ✓ Dotfiles configured for $username"
      else
        echo "  ✗ Failed to setup dotfiles for $username"
      fi
    }

    # Configura dotfiles para usuários normais
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: user:
      lib.optionalString (user.isNormalUser)
        "setup_user_dotfiles ${name} ${user.home}"
    ) config.users.users)}
  '';
}
