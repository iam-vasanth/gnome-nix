{ config, pkgs, ... }:

{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ./.secrets/git-ssh.yaml;
    secrets = {
      git_ssh_private_key = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "github.com" = {
        identityFile = config.sops.secrets.git_ssh_private_key;
      };
    };
  };
}