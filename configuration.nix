# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, callPackage, ... }:
let
  # set version for nixos
  ver = "23.05";

  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports =
    [ 
      ./hardware-configuration.nix
      <home-manager/nixos>
      # I use jellyfin for managing my media libraries. See the jellyfin.nix file for more details.
      ./containers/jellyfin.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "voyager"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # bash config
  programs.bash = {
    interactiveShellInit = ''
      # set shell to vi mode
      set -o vi
      # add scripts directory to PATH
      PATH="$PATH:/etc/nixos/shell/scripts"
    '';
    shellAliases = {
      sudo = "doas";
      v = "nvim";
      rb = "sudo nixos-rebuild";
    };
  };

  # desktop environment (gnome)
  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      autoLogin.enable = false;
      #autoLogin.user = "drew";
    };
    desktopManager = {
      gnome.enable = true;
    };
  };
  # needed for autologin (see GH issue #103746)
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;

# auto updates
  system.autoUpgrade = {
    enable = true;
    # allow to auto-reboot
    allowReboot = true;
    rebootWindow = {
      # HH:MM
      upper = "05:00";
      lower = "04:00";
    };
    # nixos-rebuild: switch or boot?
    operation = "boot";
  };

  # gnome-specific options
  # don't install the following packages
  environment.gnome.excludePackages = (with pkgs; [
    gnome-console
    gnome-photos
    gnome-tour
    gnome-connections
  ]) ++ (with pkgs.gnome; [
    gnome-music
    gnome-maps
    gnome-weather
    gnome-clocks
    gnome-calendar
    epiphany
    yelp
    geary
    gnome-characters
    totem
    tali
    iagno
    hitori
    atomix
  ]);

  programs.steam.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.drew = {
    isNormalUser = true;
    description = "drew";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # use home-manager
  home-manager.users.drew = {
    # The home.stateVersion option does not have a default and must be set
    home.stateVersion = "${ver}";

    # packages to install
    home.packages = with pkgs; [
      # gui applications
      qbittorrent                           # torrenting client
      (st.overrideAttrs (oldAttrs: rec {    # terminal emulator
        # use local config
        patches = [
          # desktop entry
          (fetchpatch {
              url = "http://st.suckless.org/patches/desktopentry/st-desktopentry-0.8.5.diff";
              sha256 = "1nhr56j2jw7llpiig8j65iwsjxkl2h96rar4nlnwrqv4mgmgsncw";
          })
        ];
        configFile = writeText "config.def.h" (builtins.readFile /etc/nixos/st/config.h);
        postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.def.h";
      }))
      freetube                              # youtube client
      jellyfin-media-player                 # jellyfin client
      discord
      spotify
      celluloid                             # mpv-based video player
      keepassxc                             # password manager
      # cli applications
      pfetch                                # system information
      ffmpeg                                # video editing
      yt-dlp                                # youtube video downloader
      #tmux
      llvmPackages.libcxxClang              # c compiler
      todo-txt-cli                          # todo list
    ];

    programs.bash = {
      enable = true;
      shellAliases = {
        # directory shortcuts
        doc = "cd $HOME/Documents";
        vid = "cd $HOME/Videos";
        mus = "cd $HOME/Music";
        # common application shortcuts
        todo = "todo.sh";
        t = "todo.sh";
      };
    };

    programs.tmux = {
      enable = true;
      prefix = "C-Space";
      keyMode = "vi";
      mouse = true;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        vim-tmux-navigator
      ];
      extraConfig = ''
        # pane resizing w/ vi keybinds
        bind-key -r -T  prefix  C-j     resize-pane -D 2
        bind-key -r -T  prefix  C-k     resize-pane -U 2
        bind-key -r -T  prefix  C-h     resize-pane -L 2
        bind-key -r -T  prefix  C-l     resize-pane -R 2

        # split in current working directory
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # sensible window indexing (start at 1 instead of 0)
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # use shift+alt and vim keys to switch windows
        bind -n M-H previous-window
        bind -n M-L next-window

        # show true term colors
        set-option -sa terminal-overrides ",xterm*:Tc"
      '';
    };

    programs.qutebrowser = {
      enable = true;
      quickmarks = {
        search = "https://search.nixos.org";
        wiki = "https://nixos.wiki";
        home-manager = "https://rycee.gitlab.io/home-manager/options.html";
        blog = "https://drewdalmedo.com";
        pipeline = "https://portal.njit.edu";
        canvas = "https://njit.instructure.com";
        pearson = "http://portal.mypearson.com";
        radio = "https://radio.lainzine.org/";
      };
      searchEngines = {
        DEFAULT="https://searx.drewdalmedo.com/searxng/search?q={}";
        g="https://www.google.com/search?hl=en&q={}";
      };
      settings = {
        # see https://qutebrowser.org/doc/help/settings.html for all available settings
        content.private_browsing = true;
        content.blocking.enabled = true;
        content.autoplay = false;
        url.start_pages = "https://searx.drewdalmedo.com";
      };
    };

    programs.newsboat = {
      enable = true;
      
      autoReload = true;

      # currently set to default, see https://rycee.gitlab.io/home-manager/options.html
      browser = "\${pkgs.xdg-utils}/bin/xdg-open";

      extraConfig = ''
        bind-key j down
        bind-key k up
        bind-key j next articlelist
        bind-key k prev articlelist
        bind-key J next-feed articlelist
        bind-key K prev-feed articlelist
        bind-key G end
        bind-key g home
        bind-key d pagedown
        bind-key u pageup
        bind-key l open
        bind-key h quit
        bind-key a toggle-article-read
        bind-key n next-unread
        bind-key N prev-unread
        bind-key D pb-download
        bind-key U show-urls
        bind-key x pb-delete
      '';

      urls = [
        {
          url = "https://lukesmith.xyz/rss.xml";
        }
        {
          url = "https://videos.lukesmith.xyz/feeds/videos.xml?videoChannelId=2";
          title = "Luke Smith (Videos)";
        }
        {
          url = "https://lindypress.net/rss";
        }
        {
          url = "https://notrelated.xyz/rss";
        }
        {
          url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCkpBmkoZ6yToHhB8uFDp46Q";
          title = "Father Spyridon (YouTube)";
        }
        {
          url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCAPSbji97w7sTw2aFe53LhA";
          title = "Giga Cheddar (YouTube)";
        }
        {
          url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCpYlPAi6ozjXYrTAZF0_0Aw";
        }
        {
          url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCtCTSf3UwRU14nYWr_xm-dQ";

        }
        {
          url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCG2J_l8-xpvxAyzwytIzELg";
        }
        {
          url = "https://n-o-d-e.net/rss/rss.xml";
          title = "N O D E (Site)";

        }
        {
          url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCvrLvII5oxSWEMEkszrxXEA";
          title = "N O D E (YouTube)";
        }
      ];
    };

    programs.gh = {
      enable = true;
    };

    programs.git = {
      enable = true;

      lfs.enable = true;

      userEmail = "andrewdalmedo@gmail.com";
      userName = "Andrew Dalmedo";
    };

  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # use doas instead of sudo
  security.sudo.enable = false;
  security.doas.enable = true;

  # configure doas
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    keepEnv = true;
    noPass = true;
  }];
  
  # enable nix commands and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl 
    hackgen-nf-font
    # gnome icon themes
    gnome.adwaita-icon-theme
    # gnome extensions
    gnomeExtensions.hibernate-status-button     # hibernation buttons
  ];

  programs.neovim = {
    enable = true;

    configure = {
      customRC = ''
        " map the leader key
        let mapleader = ','

        " bindings / mappings
        " nerdtree
        nnoremap <leader>f :NERDTreeToggle<CR>
        " vimagit
        nnoremap <leader>g :Magit<CR>
        " vimwiki
        " ...

        " other misc options
        colorscheme monokai

        set number relativenumber

        set smarttab expandtab autoindent smartindent
        set shiftwidth=2
        set tabstop=4
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        # loaded on launch
        start = [ 
          # colorscheme
          vim-monokai
          # file explorer
          nerdtree 
          # git workflow
          vimagit
          # tmux navigation
          vim-tmux-navigator
          # vimwiki
          vimwiki
          # nvim-surround
          nvim-surround
          # treesitter parsers for better syntax highlighting
          nvim-treesitter-parsers.c
          nvim-treesitter-parsers.markdown
          nvim-treesitter-parsers.nix
          nvim-treesitter-parsers.vim
          nvim-treesitter-parsers.regex
          nvim-treesitter-parsers.python
          nvim-treesitter-parsers.bash
        ];
        # manually loadable by calling ':packadd $plugin-name'
        opt = [ ];
      };
    };

    vimAlias = true;
    viAlias = true;

    defaultEditor = true;
  };

  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "8.8.8.8" ];

  # disable ipv6 (for now)
  networking.enableIPv6 = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "${ver}"; # Did you read the comment?

}
