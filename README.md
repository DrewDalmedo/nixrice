# nixrice
My NixOS configuration files.

## Installation
Currently, installation of this config must be done by manually copying all files to your `/etc/nixos` directory.
There is (as of right now) no automated way to install these config files.

Assuming there are no differences in base installation (you're using systemd-boot, same locale, same username, etc), 
one could copy the following commands:

```sh
sudo su
nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager 
nix-channel --add https://nixos.org/channels/nixos-23.05 nixos 
mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
cp -r ./configuration.nix ./st ./shell ./containers /etc/nixos/
nixos-rebuild boot
```

Then, reboot and you should have this config.

## Usage
### Overview
Most of my config is centered around (neo)vim, and includes many programs with vim-like bindings.
Bash is set to vi-mode, as is tmux. I highly recommend you read through the included configuration.nix 
file as you play around with the system so you understand the various configuration options that're being applied.
### Default Applications
- **Neovim** - the main editor. Lots of plugins and config options have been set - see configuration.nix for full details.
- **Qutebrowser** - my preferred browser. Private browsing is always on by default, and a collection of useful quickmarks are included. Run :adblock-update for adblocking.
- **st** - my preferred terminal emulator. A patch for properly displaying an icon within Gnome's taskbar is included, but it will not show up in the activities menu. Consider adding a keyboard shortcut to launch it (mine's Super-Enter). Also consider launching it with tmux: `st -e tmux` 
