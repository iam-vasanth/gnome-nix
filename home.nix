{ config, host, user, pkgs, pkgs-unstable, nix-flatpak, nixcord, sops-nix, ... }:

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11"; # Do not touch.
  
  imports = [
    ./home/pkgs.nix
    ./home/shell.nix
    ./home/gnome.nix
    ./home/nixcord.nix
    ./home/git.nix
    ./home/ssh.nix
    nix-flatpak.homeManagerModules.nix-flatpak
    nixcord.homeModules.nixcord
    sops-nix.homeManagerModules.sops
  ];

  programs.home-manager.enable = true;
}