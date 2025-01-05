{
  lib,
  stdenv,
  fetchgit,
  buildPackages,
  autoconf,
  ncurses,
  tcl,
  openssl,
  pam,
  libkrb5,
  openldap,
  libxcrypt,
  gitUpdater,
}:

stdenv.mkDerivation rec {
  pname = "alpine";
  version = "2.26";

  src = fetchgit {
    url = "https://repo.or.cz/alpine.git";
    rev = "v${version}";
    hash = "sha256-cJyUBatQBjD6RG+jesJ0JRhWghPRBACc/HQl+2aCTd0=";
  };

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  buildInputs = [
    autoconf
    ncurses
    tcl
    openssl
    pam
    libkrb5
    openldap
    libxcrypt
  ];

  hardeningDisable = [ "format" ];

  patches = [
    # gcc 14 causes the qsort test program in configure.ac to fail to compile,
    # leading configure to deduce the wrong argument type for qsort
    ./qsort-arg-type.patch
  ];

  preConfigure = "autoconf";

  configureFlags = [
    "--with-ssl-include-dir=${openssl.dev}/include/openssl"
    "--with-passfile=.pine-passfile"
    "--with-c-client-target=slx"
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = with lib; {
    description = "Console mail reader";
    license = licenses.asl20;
    maintainers = with maintainers; [
      raskin
      rhendric
    ];
    platforms = platforms.linux;
    homepage = "https://alpineapp.email/";
  };
}
