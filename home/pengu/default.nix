{ pkgs, config, ... }: {

  programs.home-manager.enable = true;

  home = {
    username = "pengu";
    homeDirectory = "/home/pengu";

    packages = with pkgs; [
      # gui
      keepassxc
      spotify
      nsxiv
      mpv
      qbittorrent
      zathura
      brave
      obsidian
      telegram-desktop

      obs-studio
      obs-studio-plugins.obs-pipewire-audio-capture

      # cli
      devenv
      tree
      htop
      fastfetch
      yt-dlp
      ffmpeg

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
      export PATH="$PATH:$HOME/.local/bin"

      export ANTHROPIC_API_KEY=$(cat /run/agenix/claude)
    '';

    shellAliases = {
      rb = "sudo nixos-rebuild";
      rbs = "sudo nixos-rebuild switch --flake";
      rbb = "sudo nixos-rebuild boot --flake";

      v = "nvim";
      vv = "nvim .";

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
}
