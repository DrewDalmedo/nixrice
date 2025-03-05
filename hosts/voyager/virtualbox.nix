{ config, pkgs, ... }:

{
  virtualisation.virtualbox = {
    host = {
      enable = false;
      #enableKvm = true;
      enableExtensionPack = true;
      #addNetworkInterface = false;
    };
  };

  users.extraGroups.vboxusers.members = [ "pengu" ];
}
