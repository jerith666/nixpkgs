{ stdenv, fetchurl, glibc } :

let
  version = "1.05";

in

stdenv.mkDerivation {
  name = "djbdns-${version}";

  src = fetchurl {
    url = "https://cr.yp.to/djbdns/djbdns-${version}.tar.gz";
    sha256 = "0j3baf92vkczr5fxww7rp1b7gmczxmmgrqc8w2dy7kgk09m85k9w";
  };

  patches = [ ./hier.patch ];

  postPatch = ''
    echo gcc -O2 -include ${glibc}/include/errno.h > conf-cc
    echo $out > conf-home
    sed -i "s|/etc/dnsroots.global|$out/etc/dnsroots.global|" dnscache-conf.c
  '';

  installPhase = ''
    mkdir -pv $out/etc;
    make setup
  '';
}