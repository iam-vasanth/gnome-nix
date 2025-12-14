{
  description = "My nix flake";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    nixy-theme.url = "github:iam-vasanth/nixy";
    # noctalia.url = "github:noctalia-dev/noctalia-shell";
    # noctalia.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  outputs = { self, nixpkgs-stable, nixpkgs-unstable, home-manager, nixy-theme, ... }:
  let
    host = "nixos-btw";
    user = "zoro";
    lib = nixpkgs-stable.lib;
    hostPlatform = "x86_64-linux";
    pkgs = import nixpkgs-stable {
      inherit hostPlatform;
      config.allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit hostPlatform;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.${host} = nixpkgs-stable.lib.nixosSystem {
      modules = [ ./configuration.nix ];
      specialArgs = {
        inherit host;
        inherit user;
        inherit pkgs-unstable;
        inherit nixy-theme;
      };
    };
    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
      extraSpecialArgs = {
        inherit host;
        inherit user;
        inherit pkgs-unstable;
      };
    };
    # nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
    #   modules = [ ./noctalia.nix ];
    # };
  };
}