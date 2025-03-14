{ config, pkgs, system, agenix, nvimrc, ... }:

{
  services.nix-daemon.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    trusted-users = [ "@admin" ];
  };

  users.users.pengu = {
    name = "pengu";
    home = "/Users/pengu";
    shell = pkgs.zsh;
  };

  system = {

    stateVersion = 4;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    agenix.packages.${system}.default

    nvimrc.packages.${system}.default
    pkgs.ripgrep
    pkgs.ltex-ls
    pkgs.python312Packages.jupytext

    pkgs.python312

    pkgs.fzf

    pkgs.kdePackages.qtmultimedia
  ];
}
