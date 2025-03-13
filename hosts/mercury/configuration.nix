{ config, pkgs, agenix, nvimrc, ... }:

{
  services.nix-daemon.enable = true;

  nixpkgs.config.allowUnfree = true;
  #nixpkgs.config.allowBroken = true;

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
    agenix.packages."x86_64-darwin".default

    nvimrc.packages."x86_64-darwin".default
    pkgs.ripgrep
    pkgs.ltex-ls
    pkgs.python312Packages.jupytext

    pkgs.python312

    pkgs.fzf

    pkgs.kdePackages.qtmultimedia
  ];
}
