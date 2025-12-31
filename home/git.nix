{ config, host, user, pkgs, pkgs-unstable, ... }:

{
  programs.git = {
    enable = true;

    userName = "iam-vasanth";
    userEmail = "vk.vasanth.r@gmail.com";

    ignores = [
      "*.swp"
      "*~"
      ".DS_Store"
      ".direnv/"
      "result"
      "result-*"
    ];

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

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        editor = "zed --wait";
      };
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
      };
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
        "git@gitlab.com:" = {
          insteadOf = "https://gitlab.com/";
        };
      };
    };
  };
}