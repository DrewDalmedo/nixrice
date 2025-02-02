{
  description = "Drew's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11" ;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "git+https://codeberg.org/quasigod/nur.git";

    agenix.url = "github:ryantm/agenix";

    nvimrc.url = "github:DrewDalmedo/nixvimrc";
  };

  outputs = { self, nixpkgs, home-manager, agenix, nvimrc, nur, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkSystem = { hostname, system ? "x86_64-linux" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs nvimrc agenix hostname nur; };

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
