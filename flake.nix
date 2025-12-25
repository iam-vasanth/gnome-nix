{
  description = "My nix flake";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    plymouth-nixy = {
      url = "github:iam-vasanth/plymouth-nixy";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = { self, nixpkgs-stable, nixpkgs-unstable, home-manager, nix-flatpak, plymouth-nixy, ... }:
  let
    host = "enma";
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
    nixosConfigurations.${host} = nixpkgs-stable.lib.nixosSystem {
      inherit system;
      modules = [ ./configuration.nix ];
      specialArgs = {
        inherit host;
        inherit user;
        inherit pkgs-unstable;
        inherit plymouth-nixy;
      };
    };
    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
      extraSpecialArgs = {
        inherit host;
        inherit user;
        inherit pkgs;
        inherit pkgs-unstable;
        inherit nix-flatpak;
      };
    };
  };
}