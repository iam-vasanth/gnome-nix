{ config, host, user, pkgs, pkgs-unstable, ... }:

{
  programs.git = {
    enable = true;
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
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
        "git@gitlab.com:" = {
          insteadOf = "https://gitlab.com/";
        };
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
      };
    };
  };
}