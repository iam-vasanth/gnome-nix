{ config, ... }:

{
  programs.git = {
    enable = true;
    signing = {
      key = "${config.home.homeDirectory}/.ssh/github_ssh.pub";
      signByDefault = true;
      format = "ssh";
    };
    ignores = [
      "*.swp"
      "*~"
      ".DS_Store"
      ".direnv/"
      "result"
      "result-*"
    ];
    settings = {
      user.name = "iam-vasanth";
      user.email = "vk.vasanth.r@gmail.com";

      aliases = {
        co    = "checkout";
        br    = "branch";
        ci    = "commit";
        st    = "status";
        ps    = "push";
        pl    = "pull";
        aa    = "add .";
        unstage = "reset HEAD --";
        lg    = "log --oneline --graph --decorate";
      };

      url = {
        "git@github.com:" = { insteadOf = "https://github.com/"; };
        "git@gitlab.com:" = { insteadOf = "https://gitlab.com/"; };
      };

      extraConfig = {
        init.defaultBranch = "main";
        core.editor = "zed --wait";
        pull.rebase = true;
        push.autoSetupRemote = true;
        "gpg.ssh".allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
        tag.gpgSign = true;
      };
    };
  };
  home.file.".config/git/allowed_signers".text = let
    pubKey = builtins.readFile "${config.home.homeDirectory}/.ssh/github_ssh.pub";
  in ''
    vk.vasanth.r@gmail.com namespaces="git" ${pubKey}
  '';
}
