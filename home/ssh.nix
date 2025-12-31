{ config, pkgs, sops-nix, ... }:

{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = builtins.path {
      path = ./.secrets/git-ssh.yaml;
      name = "git-ssh-yaml";
    };
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
        hostname = "github.com";
        user = "git";
        identityFile = config.sops.secrets.git_ssh_private_key.path;
      };
    };
  };
}