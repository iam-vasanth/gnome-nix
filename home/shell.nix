{ config, host, user, ... }:

{
  home.sessionVariables = {
    EDITOR = "neovim";
  };

  # Bash config
  programs.bash = {
    enable = true;
    shellAliases = {
      "ll" = "ls -alh";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --impure --flake ~/gnome-nix";
      flakeu  = "nix flake update --flake ~/gnome-nix";
      hupdate = "home-manager switch --impure --flake ~/gnome-nix";
      "gs" = "git status";
      };
  };
}