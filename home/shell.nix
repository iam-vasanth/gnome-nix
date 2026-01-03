{ ... }:

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
      rebuild = "sudo nixos-rebuild switch --impure --flake ~/Projects/gnome-nix";
      flakeu  = "nix flake update --flake ~/Projects/gnome-nix";
      hupdate = "home-manager switch --impure --flake ~/Projects/gnome-nix";
      "gs" = "git status";
      };
  };
}
