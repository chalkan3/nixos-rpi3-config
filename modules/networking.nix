{ config, pkgs, ... }:

{
  # Hostname
  networking.hostName = "lady-guica";
  
  # Ethernet apenas - sem WiFi
  networking.useDHCP = false;
  networking.interfaces.enu1u1u1.useDHCP = true;
}
