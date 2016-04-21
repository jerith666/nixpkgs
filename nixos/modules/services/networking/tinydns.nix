{ config, lib, pkgs, ... }:

with lib;

let

  dataFile = pkgs.writeText "tinydns-data" config.services.tinydns.data;

in

{

  ###### interface

  options = {
    services.tinydns = {
      enable = mkOption {
        default = false;
        description = "Whether to run the tinydns dns server";
      };

      data = mkOption {
        description = "The DNS data to serve, in the format described by tinydns-data(8)";
      };

      ip = mkOption {
        default = "0.0.0.0";
        description = "IP address on which to listen for connections";
      };
    };
  };

  ###### implementation

  config = mkIf config.services.tinydns.enable {
    environment = {
      systemPackages = [ pkgs.djbdns ];
    };

    users = {
      extraGroups.tinydns = {
        gid = config.ids.gids.tinydns;
      };

      extraUsers.tinydns = {
        uid = config.ids.uids.tinydns;
        description = "tinydns user";
        group = "tinydns";
      };
    };

    systemd.services.tinydns = {
      description = "djbdns tinydns server";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ daemontools djbdns ];
      preStart = ''
        rm -rf /var/lib/tinydns;
        tinydns-conf tinydns tinydns /var/lib/tinydns ${config.services.tinydns.ip};
        cd /var/lib/tinydns/root/;
        rm data;
        ln -s ${dataFile} data;
        tinydns-data;
      '';
      script = ''
        cd /var/lib/tinydns;
        ./run;
      '';
    };
  };
}