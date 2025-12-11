{ config, host, user, pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel params
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "vt.global_cursor_default=0"
  ];

  # Silences systemd logs
  systemd.settings = {
    Manager = {
      ShowStatus = "no";
      DefaultStandardOutput = "null";
    };
  };

  # Nixy plymouth theme
  nixpkgs.config.packageOverrides = pkgs: rec {
    nixyTheme = pkgs.callPackage /home/zoro/gnome-nix/nixy-theme.nix {};
  };

  boot.plymouth = {
    enable = true;
    theme = "nixy";
    themePackages = [ pkgs.nixyTheme ];
  };

  # Hide systemd boot menu (press Space to show it when needed)
  # boot.loader.timeout = 0;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Hostname
  networking.hostName = "${host}";

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable Niri
  # programs.niri.enable = true;
  # Enable Ly display manager
  # services.displayManager.ly.enable = true;
  # Noctalia essentials
  # hardware.bluetooth.enable = true;
  # services.power-profiles-daemon.enable = true;
  # services.upower.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "ZORO";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "fuse" "video" ];
    packages = with pkgs; [
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # To enable Vmware guest tools
  virtualisation.vmware.guest.enable = true;

  # Mounting Vmware shared folder
  fileSystems."/home/zoro/gnome-nix" = {
    device = ".host:/gnome-nix";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [ "umask=22" "uid=1000" "allow_other" "auto_unmount" "defaults" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    fuse
    fuse3
    dos2unix
    imagemagick
    nixyTheme # Personal nix plymouth theme
  ];
  
  # Automatically garbage collect old generations
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d +5";
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };

  system.stateVersion = "25.11"; # Do not touch this
}