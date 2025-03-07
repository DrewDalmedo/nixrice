{ pkgs, config, ... }: {

  programs.home-manager.enable = true;

  home = {
    username = "pengu";
    homeDirectory = "/home/pengu";

    packages = with pkgs; [
      # gui
      keepassxc
      nsxiv
      mpv
      qbittorrent
      zathura
      brave
      obsidian
      telegram-desktop
      libreoffice-qt6-fresh
      mgba
      signal-desktop

      # cli
      devenv
      tree
      htop
      fastfetch
      yt-dlp
      ffmpeg
      typst

      # misc
      nerdfonts
    ];

    # copy scripts from local dir to "~/.local/bin"
    file.".local/bin" = {
      source = ./scripts;
      recursive = true;
      executable = true;
    };

    sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
    };

    stateVersion = "24.11";
  };

  fonts.fontconfig.enable = true;

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;

      theme = "candy";
    };

    initExtra = ''
      set -o vi

      export PATH="$PATH:$HOME/.local/bin"

      export ANTHROPIC_API_KEY=$(cat /run/agenix/claude)
    '';

    shellAliases = {
      rb = "sudo nixos-rebuild";
      rbs = "sudo nixos-rebuild switch --flake";
      rbb = "sudo nixos-rebuild boot --flake";

      gc = "sudo nix-collect-garbage";
      gcd = "sudo nix-collect-garbage -d";

      v = "nvim";
      vv = "nvim +Ex";

      z = "zathura --fork";

      dv = "devenv";
      dvi = "devenv init";
      dvs = "devenv shell";

      fetch = "fastfetch";
      open = "xdg-open";

      cdf = "cd $(sd)";

      cp = "cp -v";

    };
  };

  programs.git = {
    enable = true;
    userName = "Drew Dalmedo";
    userEmail = "andrewdalmedo@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
    };
  };

  programs.ghostty = {
    enable = true;

    settings = {
      theme = "GruvboxDark";

      font-family = "UbuntuMono Nerd Font Mono";
      font-size = 16;

      gtk-titlebar = false;
      gtk-adwaita = false;

      mouse-hide-while-typing = true;
    };
  };
}
