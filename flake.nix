{
  description = "My nix flake";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nixcord.url = "github:kaylorben/nixcord";
  };
  outputs = { self, nixpkgs-stable, nixpkgs-unstable, home-manager, nix-flatpak, nixcord, flake-utils, ... }:
  flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system: let
    host = "enma";
    user = "zoro";
    pkgs = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    commonSpecialArgs = {
      inherit host;
      inherit user;
      inherit pkgs;
      inherit pkgs-unstable;
      inherit nix-flatpak;
      inherit nixcord;
    };
  in {
    nixosConfigurations.${host} = nixpkgs-stable.lib.nixosSystem {
      inherit system;
      modules = [ ./configuration.nix ];
      specialArgs = commonSpecialArgs;
    };
    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
      extraSpecialArgs = commonSpecialArgs;
    };
  });
}