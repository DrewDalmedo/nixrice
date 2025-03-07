{
  description = "Drew's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11" ;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    nvimrc.url = "github:DrewDalmedo/nixvimrc";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, nvimrc, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # overlay to selectively use unstable packages
      unstableOverlay = final: prev: {
        typst = nixpkgs-unstable.legacyPackages.${system}.typst;
      };
      
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ unstableOverlay ];
      };

      mkSystem = { hostname, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs nvimrc agenix hostname; };

          modules = [
            # system config
            ./hosts/${hostname}/configuration.nix

            # home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                backupFileExtension = "bak";

                users.pengu = import ./home/pengu;
              };
            }

            # agenix secret management
            agenix.nixosModules.default

          ];
        };
    in {
      nixosConfigurations = {
        "voyager" = mkSystem {
          hostname = "voyager";
        };

        "jupiter" = mkSystem {
          hostname = "jupiter";
        };
      };
    };
}
