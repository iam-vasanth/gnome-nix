{
  description = "My nix flake";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
    nixy-theme = {
      url = "github:iam-vasanth/plymouth-nixy";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = { self, nixpkgs-stable, nixpkgs-unstable, home-manager, zen-browser, nixy-theme, ... }:
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
    nixosConfigurations.${host} = nixpkgs-stable.lib.nixosSystem {
      inherit system;
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
        inherit zen-browser;
      };
    };
  };
}