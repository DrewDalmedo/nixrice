#!/usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p bash

# Placeholder script for updating config files.
#
# Takes one parameter: the name of the user which should own the files in this directory.
# THIS IS NOT A GOOD SOLUTION AND SHOULD BE CHANGED IN THE NEAR FUTURE!

rm -rf ./st ./shell ./containers ./configuration.nix
cp -r /etc/nixos/* ./.
chown -R $1 *
rm ./hardware-configuration.nix
