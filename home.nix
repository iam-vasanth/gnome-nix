{ config, host, user, pkgs, pkgs-unstable, ... }:

{
  home.username = "zoro";
  home.homeDirectory = "/home/zoro";
  home.stateVersion = "25.11"; # Do not touch.

  home.packages = [
  ];

  home.file = {
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Bash config
  programs.bash = {
  enable = true;
  shellAliases = {
    "ll" = "ls -alh";
    ".." = "cd ..";
    "rebuild" = "sudo nixos-rebuild switch --impure --flake /home/zoro/gnome-nix";
    "flakeu" = "nix flake update --flake /home/zoro/gnome-nix";
    "hupdate" = "home-manager switch --flake /home/zoro/gnome-nix";
    "gs" = "git status";
    };
  };



  programs.home-manager.enable = true;
}