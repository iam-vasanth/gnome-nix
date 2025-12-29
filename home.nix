{ config, host, user, pkgs, pkgs-unstable, nix-flatpak, ... }:

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11"; # Do not touch.
  
  imports = [
    ./home/pkgs.nix
    ./home/shell.nix
    ./home/gnome.nix
    ./home/vesktop.nix
    nix-flatpak.homeManagerModules.nix-flatpak
  ];

  programs.home-manager.enable = true;
}