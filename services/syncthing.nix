{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = false;
    openDefaultPorts = true;

    settings = {
      folders = {
        "Sync" = {
          path = "/home/pengu/.local/sync";
          # sync file permissions
          ignorePerms = false; 
        };
      };  
    };
  };

  # disable default sync folder
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
