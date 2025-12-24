{ config, host, user, pkgs, pkgs-unstable, plymouth-nixy, ... }:

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # Plymouth configuration
  boot.plymouth = {
    enable = true;
    theme = "nixy";
    themePackages = [ plymouth-nixy.packages.x86_64-linux.default ];
  };

  # Hide systemd boot menu (press Space to show it when needed)
  # boot.loader.timeout = 3;
  
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # Enables flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enables networking
  networking.networkmanager.enable = true;

  # Hostname
  networking.hostName = "${host}";

  # Sets your time zone.
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
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enables flatpak
  services.flatpak.enable = true; 

  # Enables CUPS to print documents.
  services.printing.enable = true;

  # Enables sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support.
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "ZORO";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "fuse" "video" ];
    packages = with pkgs; [
    ];
  };

  # To enable Vmware guest tools
  virtualisation.vmware.guest.enable = true;

  # Mounting Vmware shared folder
  fileSystems."/home/zoro/gnome-nix" = {
    device = ".host:/gnome-nix";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [ "nofail" "umask=22" "uid=1000" "allow_other" "auto_unmount" "defaults" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.wget
    pkgs.git
    pkgs.fuse
    pkgs.fuse3
    pkgs.dos2unix
    pkgs.imagemagick
    pkgs.neovim
    pkgs.unstable.distrobox
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