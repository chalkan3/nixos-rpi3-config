{ config, pkgs, ... }:

{
  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # Firewall desabilitado
  networking.firewall.enable = false;
}
