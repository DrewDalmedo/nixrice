{ pkgs, config, ... }: {

  programs.home-manager.enable = true;

  home = {
    username = "pengu";

    packages = with pkgs; [
      # gui
      keepassxc
      nsxiv
      mpv
      qbittorrent
      #zathura
      brave
      obsidian
      telegram-desktop
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
      (nerdfonts.override { fonts = [ "UbuntuMono" ]; })
      # TODO: change line above to the line below after updating to 25.05
      #nerd-fonts.ubuntu-mono
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
      rb = if pkgs.stdenv.isDarwin then "darwin-rebuild" else "sudo nixos-rebuild";
      rbs = if pkgs.stdenv.isDarwin then "darwin-rebuild switch --flake" else  "sudo nixos-rebuild switch --flake";
      rbb = "sudo nixos-rebuild boot --flake"; # NixOS only

      gc = "sudo nix-collect-garbage";
      gcd = "sudo nix-collect-garbage -d";

      v = "nvim";
      vv = "nvim +Ex";

      z = "zathura --fork";

      dv = "devenv";
      dvi = "devenv init";
      dvs = "devenv shell";

      fetch = "fastfetch";
      open = if pkgs.stdenv.isDarwin then "open" else "xdg-open";

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
    # Ghostty 1.1.2 is broken on macOS, look into re-enabling later
    # kitty should be used in the meantime
    enable = false;

    settings = {
      theme = "GruvboxDark";

      font-family = "UbuntuMono Nerd Font Mono";
      font-size = 16;

      gtk-titlebar = false;
      gtk-adwaita = false;

      mouse-hide-while-typing = true;
    };
  };

  programs.kitty = {
    enable = true;

    themeFile = "gruvbox-dark";

    settings = {
      font_family = "UbuntuMono Nerd Font Mono";
      font_size = "16";
    };
  };

  programs.zathura = {
    enable = true;
    extraConfig = ''
      set selection-clipboard clipboard
    '';
  };
}
