{ config, pkgs, ... }:

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
    # Usuário padrão do NixOS
    nixos = newUser "nixos" "nixos" "Nixos Default User";

    # Seu usuário personalizado
    # IMPORTANTE: Mude o nome de usuário e senha!
    chalkan3 = newUser "chalkan3" "change-me-please" "Your User";

    # Senha do root
    root.initialPassword = "change-me-too";
  };
}
