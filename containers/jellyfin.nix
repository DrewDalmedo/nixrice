{ config, pkgs, ... }:

{

  # Jellyfin
  virtualisation.oci-containers.containers."jellyfin" = {
    autoStart = true;
    image = "jellyfin/jellyfin";
    volumes = [
      "/media/Containers/Jellyfin/config:/config"
      "/media/Containers/Jellyfin/cache:/cache"
      "/media/Containers/Jellyfin/log:/log"
      "/media/Movies:/movies"
      "/media/TV:/tv"
      "/media/Anime:/anime"
    ];
    ports = [ "8096:8096" ];
    environment = {
      JELLYFIN_LOG_DIR = "/log";
    };
  };

}
