{
  description = "Drew's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11" ;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    agenix.url = "github:ryantm/agenix";

    nvimrc.url = "github:DrewDalmedo/nixvimrc";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, darwin, mac-app-util, agenix, nvimrc, ... }@inputs:
    let
      # overlay to selectively use unstable packages
      unstableOverlay = system: final: prev: {
        typst = nixpkgs-unstable.legacyPackages.${system}.typst;
      };
      
      mkPkgs = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [ (unstableOverlay system) ];
      };

      mkSystem = { hostname, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { 
            inherit inputs nvimrc agenix hostname;
            pkgs = mkPkgs system;
          };

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
      mkDarwinSystem = { hostname, system ? "x86_64-darwin" }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { 
            inherit system inputs nvimrc agenix hostname;
            pkgs = mkPkgs system;
          };
          
          modules = [
            ./hosts/mercury/configuration.nix

            # mac-app-util (properly populates Spotlight and ~/Applications)
            mac-app-util.darwinModules.default

            # home-manager
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                backupFileExtension = "bak";

                sharedModules = [
                  mac-app-util.homeManagerModules.default
                ];

                users.pengu = import ./home/pengu;
              };
            }

            # agenix secret management
            agenix.darwinModules.default
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

      darwinConfigurations = {
        "mercury" = mkDarwinSystem {
          hostname = "mercury";
        };
      };
    };
}
