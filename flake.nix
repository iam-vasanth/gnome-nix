{
  description = "My nix flake";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
  };
  outputs = { self, nixpkgs-stable, home-manager, ... }:
  let
    host = nixos-btw;
    user = zoro;
    stable = nixpkgs-stable.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.host = stable.nixosSystem {
      inherit system;
      modules = [ ./configuration.nix ];
    };
  };
  homeConfigurations.user = home-manager.lib.homemanagerConfiguration {
    inherit pkgs;
    modules = [ ./home.nix ];
  };
}