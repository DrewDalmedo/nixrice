{ config, pkgs, system, agenix, nvimrc, ... }:

{
  services.nix-daemon.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    trusted-users = [ "@admin" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  users.users.pengu = {
    name = "pengu";
    home = "/Users/pengu";
    shell = pkgs.zsh;
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    stateVersion = 4;
  };

  # script to remap caps lock to escape on startup
  launchd.user.agents."remap-capslock" = {
    serviceConfig = {
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--set"
        "{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":0x700000039, \"HIDKeyboardModifierMappingDst\":0x700000029}]}"
      ];
      RunAtLoad = true;
    };
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
