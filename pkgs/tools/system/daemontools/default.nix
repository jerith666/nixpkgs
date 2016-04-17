{ stdenv, fetchurl, glibc, coreutils } :

#coreutils needed for tests

let
  version = "0.76";

in

stdenv.mkDerivation{
  name = "daemontools-${version}";

  src = fetchurl {
    url = "https://cr.yp.to/daemontools/daemontools-${version}.tar.gz";
    sha256 = "07scvw88faxkscxi91031pjkpccql6wspk4yrlnsbrrb5c0kamd5";
  };

  sourceRoot = "admin/daemontools-${version}";

  patches = [ ./rts.tests.patch ./upgrade.patch ./run.patch ];

  postPatch = ''
    sed -i 's|\(^.*$\)|\1 -include ${glibc}/include/errno.h|' src/conf-cc;
  '';

  buildPhase = ''
    ./package/install
  '';

  installPhase = ''
    mkdir -p $out/bin;
    cp -v command/* $out/bin;
  '';
}
