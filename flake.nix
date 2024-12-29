{
  description = "Drew's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11" ;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvimrc.url = "github:DrewDalmedo/nixvimrc";
  };

  outputs = { self, nixpkgs, home-manager, nvimrc, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkSystem = { hostname, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs nvimrc hostname; };

          modules = [
            # system config
            ./hosts/${hostname}/configuration.nix

            # home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users.pengu = import ./home/pengu;
            }
          ];
        };
    in {
      nixosConfigurations = {
        "voyager" = mkSystem {
          hostname = "voyager";
        };
      };
    };
}
