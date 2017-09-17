{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dnscache;

  touchIpsCmd = concatStringsSep "\n"
                  (map (ip: ("touch /var/lib/dnscache/root/ip/" + ip))
                       cfg.clientIps);

  makeHostfilesCmd = concatStringsSep "\n"
                       (mapAttrsToList (host: server:
                                        "echo '" + server + "' > /var/lib/dnscache/root/servers/" + host)
                        cfg.domainServers);

in

{

  ###### interface

  options = {
    services.dnscache = {
      enable = mkOption {
        default = false;
        description = "Whether to run the dnscache caching dns server";
      };

      ip = mkOption {
        default = "0.0.0.0";
        description = "IP address on which to listen for connections";
      };

      clientIps = mkOption {
        default = [ "127.0.0.1" ];
        description = "client IP addresses (or prefixes) from which to accept connections";
      };

      domainServers = mkOption {
        default = {};
        description = "table of {hostname: server} pairs to use as authoritative servers for hosts (and subhosts)";
      };
    };
  };

  ###### implementation

  config = mkIf config.services.dnscache.enable {
    environment = {
      systemPackages = [ pkgs.djbdns ];
    };

    users = {
      extraGroups.dnscache = {
        gid = config.ids.gids.dnscache;
      };

      extraUsers.dnscache = {
        uid = config.ids.uids.dnscache;
        description = "dnscache user";
        group = "dnscache";
      };
    };

    systemd.services.dnscache = {
      description = "djbdns dnscache server";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ bash daemontools djbdns ];
      preStart = ''
        rm -rf /var/lib/dnscache;
        dnscache-conf dnscache dnscache /var/lib/dnscache ${config.services.dnscache.ip};
        ${touchIpsCmd}
        ${makeHostfilesCmd}
      '';
      script = ''
        cd /var/lib/dnscache;
        ./run;
      '';
    };
  };
}