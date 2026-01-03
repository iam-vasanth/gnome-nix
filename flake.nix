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
    nixcord.url = "github:kaylorben/nixcord";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };
  outputs = { nixpkgs-stable, nixpkgs-unstable, home-manager, nix-flatpak, nixcord, sops-nix, ... }:
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
  in
  {
    nixosConfigurations.${host} = lib.nixosSystem {
      inherit system;
      modules = [ ./configuration.nix ];
      specialArgs = { inherit host user pkgs pkgs-unstable; };
    };
    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
      extraSpecialArgs = { inherit host user pkgs pkgs-unstable nix-flatpak nixcord sops-nix; };
    };
  };
}
