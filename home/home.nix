{ config, host, user, pkgs, pkgs-unstable, nix-flatpak, ... }:

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11"; # Do not touch.
  
  imports = [
    ./pkgs.nix
    ./shell.nix
    ./gnome.nix
    # ./vesktop.nix
    nix-flatpak.homeManagerModules.nix-flatpak
  ];

  programs.home-manager.enable = true;
}