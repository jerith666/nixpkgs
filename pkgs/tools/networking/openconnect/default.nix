{ lib, stdenv, fetchurl
, pkg-config
, openssl ? null, gnutls ? null
, gmp, libxml2, stoken, zlib
, vpnc-scripts
, PCSC
} :

assert (openssl != null) == (gnutls == null);

stdenv.mkDerivation rec {
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
    "--with-vpnc-script=${vpnc-scripts}/bin/vpnc-script"
    "--disable-nls"
    "--without-openssl-version-check"
  ];

  buildInputs = [ openssl gnutls gmp libxml2 stoken zlib ]
    ++ lib.optional stdenv.isDarwin PCSC;
  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "VPN Client for Cisco's AnyConnect SSL VPN";
    homepage = "https://www.infradead.org/openconnect/";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ pradeepchhetri tricktron ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
