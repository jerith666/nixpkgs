{ stdenv, fetchurl, glibc, coreutils } :

#coreutils needed for tests

let
  version = "0.76";

  manSrc = fetchurl {
    url = "http://smarden.org/pape/djb/manpages/daemontools-${version}-man-20020131.tar.gz";
    sha256 = "02k06k2f69jl758cz6hfmnvzxq5vyyik29b7hzshv2l7w2ppfk8v";
  };

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
    cd $out;
    tar xzvf ${manSrc};
    mkdir -v man;
    mv -iv daemontools-man man/man8;
  '';
}
