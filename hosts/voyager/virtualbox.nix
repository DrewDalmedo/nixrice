{ config, pkgs, ... }:

{
  virtualisation.virtualbox = {
    host = {
      enable = true;
      #enableKvm = true;
      enableExtensionPack = true;
      #addNetworkInterface = false;
    };
  };

  users.extraGroups.vboxusers.members = [ "pengu" ];
}
