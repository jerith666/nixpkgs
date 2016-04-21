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
    };
  };

  ###### implementation

  config = mkIf config.services.tinydns.enable {
    environment = {
      systemPackages = [ pkgs.djbdns ];
    };

    systemd.services.tinydns = {
      description = "djbdns tinydns server";
      path = [ pkgs.djbdns ];
      preStart = ''
        rm -rf /var/lib/tinydns;
	tinydns-conf tinydns tinydns /var/lib/tinydns ip;
	cd /var/lib/tinydns/root/;
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