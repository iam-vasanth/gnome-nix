{ pkgs, pkgs-unstable, ... }:

{
  home.packages = [
    pkgs.spotify-player
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
}