{
  description = "My nix flake";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    # nixy-theme.url = "github:iam-vasanth/nixy";
    # noctalia.url = "github:noctalia-dev/noctalia-shell";
    # noctalia.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  outputs = { self, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }:
  let
    host = "nixos-btw";
    user = "zoro";
    lib = nixpkgs-stable.lib;
    system = "x86_64-linux";
    pkgs = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.${host} = lib.nixosSystem {
      inherit system;
      modules = [ ./configuration.nix ];
      specialArgs = {
        inherit host;
        inherit user;
        inherit pkgs-unstable;
        # inherit nixy-Ptheme;
      };
    };
    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
      extraSpecialArgs = {
        inherit host;
        inherit user;
        inherit pkgs-unstable;
        # inherit nixy-Ptheme;
      };
    };
    # nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
    #   modules = [ ./noctalia.nix ];
    # };
  };
}