{ config, host, user, pkgs, pkgs-unstable, ... }:

{
  home.username = "zoro";
  home.homeDirectory = "/home/zoro";
  home.stateVersion = "25.11"; # Do not touch.

  # Allow unfree packages in home-manager
  nixpkgs.config.allowUnfree = true;
  
  home.packages = with pkgs-unstable; [
    vscode
    alacritty
  ];

  home.file = {
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.user-themes; }
      { package = pkgs.gnomeExtensions.dash-to-dock; }
      { package = pkgs.gnomeExtensions.clipboard-indicator; }
      { package = pkgs.gnomeExtensions.appindicator; }
      { package = pkgs.gnomeExtensions.blur-my-shell; }
      { package = pkgs.gnomeExtensions.just-perfection; }
    ];
  };
# Have to see if extensions configurations can be copied since there is no home-manager options for them.

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