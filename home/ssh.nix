{ config, user, ... }:

{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = /home/${user}/gnome-nix/.secrets/github_ssh.yaml;
    secrets = {
      github_ssh = {
        path = "${config.home.homeDirectory}/.ssh/github_ssh";
        mode = "0600";
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = config.sops.secrets.github_ssh.path;
        addKeysToAgent = "yes";
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };
}
