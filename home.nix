{ config, host, user, pkgs, pkgs-unstable, nix-flatpak, ... }:

{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.11"; # Do not touch.
  
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
  ];

  home.packages = [
    pkgs-unstable.alacritty
  ];

  services.flatpak = {
  enable = true;
  packages = [
    { appId = "app.zen_browser.zen"; origin = "flathub"; }
    { appId = "com.spotify.Client"; origin = "flathub"; }
    { appId = "de.haeckerfelix.Fragments"; origin = "flathub"; }
    { appId = "com.belmoussaoui.Authenticator"; origin = "flathub"; }
    { appId = "com.github.tchx84.Flatseal"; origin = "flathub"; }
    { appId = "org.fedoraproject.MediaWriter"; origin = "flathub"; }
    { appId = "org.videolan.VLC"; origin = "flathub"; }
    { appId = "io.gitlab.adhami3310.Impression"; origin = "flathub"; }
    { appId = "com.ranfdev.DistroShelf"; origin = "flathub"; }
    { appId = "io.github.flattool.Warehouse"; origin = "flathub"; }
    { appId = "org.upscayl.Upscayl"; origin = "flathub"; }
    { appId = "md.obsidian.Obsidian"; origin = "flathub"; }
    { appId = "com.stremio.Stremio"; origin = "flathub"; }
    # { appId = "flathub:com.ml4w.dotfilesinstaller"; origin = "flathub" } # For dotfiles management
  ];
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    music = "${config.home.homeDirectory}/Music";
    publicShare = null;
    templates = null;
    desktop = null;
  };

  home.file = {
    ".config/gtk-3.0/bookmarks".text = ''
      file://${config.home.homeDirectory}/Downloads
      file://${config.home.homeDirectory}/Documents
      file://${config.home.homeDirectory}/Projects
      file://${config.home.homeDirectory}/Pictures
      file://${config.home.homeDirectory}/Videos
      file://${config.home.homeDirectory}/Music
    '';
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
      rebuild = "sudo nixos-rebuild switch --impure --flake ~/gnome-nix";
      flakeu  = "nix flake update --flake ~/gnome-nix";
      hupdate = "home-manager switch --impure --flake ~/gnome-nix";
      "gs" = "git status";
      };
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
  
  dconf.settings = {
    # Set wallpaper
    "org/gnome/desktop/background" = {
      picture-uri = "file://${config.xdg.userDirs.pictures}/Wallpapers/wall-4.png";
      picture-uri-dark = "file://${config.xdg.userDirs.pictures}/Wallpapers/wall-4.png";
      picture-options = "zoom";
    };
    "org/gnome/desktop/interface" = {
      accent-color="red";
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita";
      enable-animations=true;
      enable-hot-corners=false;
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
    };
    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state=true;
    };
    "org/gnome/desktop/session" = {
      idle-delay=0;
    };
    "org/gnome/desktop/notifications" = {
      show-banners=false;
    };
    "org/gnome/desktop/wm/keybindings" = {
      move-to-workspace-1=["<Shift><Super>1"];
      move-to-workspace-2=["<Shift><Super>2"];
      move-to-workspace-3=["<Shift><Super>3"];
      move-to-workspace-4=["<Shift><Super>4"];
      switch-to-workspace-1=["<Super>1"];
      switch-to-workspace-2=["<Super>2"];
      switch-to-workspace-3=["<Super>3"];
      switch-to-workspace-4=["<Super>4"];
      show-desktop=["<Super>d"];
    };
    # Ext : Just perfection
    "org/gnome/Console" = {
      font-scale=0.99999999999999989;
      last-window-maximised=true;
      last-window-size=[732 528];
    };
    "org/gnome/control-center" = {
      last-panel="background";
      window-state=[980 640 0];
    };
    "org/gnome/shell/extensions/just-perfection" = {
      theme=true;
    };
    # Ext : Dash to dock
    "org/gnome/shell" = {
      disable-user-extensions=false;
      favorite-apps=[ "org.gnome.Nautilus.desktop" "Alacritty.desktop" ];  # Pinned dock apps
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme=true;
      background-opacity=0.80000000000000004;
      dance-urgent-applications=false;
      dash-max-icon-size=42;
      dock-position="BOTTOM";
      height-fraction=0.90000000000000002;
      hot-keys=false;
      preferred-monitor=-2;
      scroll-to-focused-application=true;
      show-apps-always-in-the-edge=false;
      show-icons-emblems=false;
      show-mounts=false;
      show-mounts-only-mounted=false;
      show-show-apps-button=false;
      show-trash=false;
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden=true;
    };
  };
  programs.home-manager.enable = true;
}