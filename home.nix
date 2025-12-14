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

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
  };

  gtk.gtk3.bookmarks = [
    "file://${config.home.homeDirectory}/Documents"
    "file://${config.home.homeDirectory}/Downloads"
    "file://${config.home.homeDirectory}/Music"
    "file://${config.home.homeDirectory}/Pictures"
    "file://${config.home.homeDirectory}/Videos"
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
/* Extensions can be configured with dconf options but to know the various options for various extension.
   Have to dump the dconf settings using https://github.com/nix-community/dconf2nix */
   
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