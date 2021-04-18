{ lib, stdenv, fetchurl, fetchgit,
  pkg-config, makeWrapper,
  openssl ? null, gnutls ? null,
  gmp, libxml2, stoken, zlib,
  nettools, gawk, openresolv, coreutils, gnugrep,
  PCSC
} :

assert (openssl != null) == (gnutls == null);

let
  os = if stdenv.isDarwin then "Darwin" else "Linux";

  vpnc = stdenv.mkDerivation {
    name = "vpnc-scripts-c0122e891f7";
    src = fetchgit {
      url = "git://git.infradead.org/users/dwmw2/vpnc-scripts.git";
      rev = "c0122e891f7e033f35f047dad963702199d5cb9e";
      sha256 = "11b1ls012mb704jphqxjmqrfbbhkdjb64j2q4k8wb5jmja8jnd14";
    };

    buildInputs = [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      cp vpnc-script $out/bin

      substituteInPlace $out/bin/vpnc-script \
        --replace "which" "type -P" \
        --replace "/sbin/resolvconf" "${openresolv}/bin/resolvconf"

      wrapProgram $out/bin/vpnc-script \
        --set OS ${os} \
        --prefix PATH : "${lib.makeBinPath [nettools gawk openresolv coreutils gnugrep]}"
    '';
  };

in stdenv.mkDerivation rec {
  pname = "openconnect";
  version = "8.10";

  src = fetchurl {
    urls = [
      "ftp://ftp.infradead.org/pub/openconnect/${pname}-${version}.tar.gz"
    ];
    sha256 = "1cdsx4nsrwawbsisfkldfc9i4qn60g03vxb13nzppr2br9p4rrih";
  };

  outputs = [ "out" "dev" ];

  configureFlags = [
    "--with-vpnc-script=${vpnc}/bin/vpnc-script"
    "--disable-nls"
    "--without-openssl-version-check"
  ];

  buildInputs = [ openssl gnutls gmp libxml2 stoken zlib ]
    ++ lib.optional stdenv.isDarwin PCSC;
  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "VPN Client for Cisco's AnyConnect SSL VPN";
    homepage = "http://www.infradead.org/openconnect/";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ pradeepchhetri tricktron ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
