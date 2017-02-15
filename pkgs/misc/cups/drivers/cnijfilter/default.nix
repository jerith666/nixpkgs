# { stdenv, lib, fetchzip, autoconf, automake, cups, glib, libxml2, libusb, libtool
# , withDebug ? false }:

{ stdenv, lib, fetchzip,
  autoconf, automake, libtool,
  cups, popt }:

stdenv.mkDerivation rec {
  name = "cnijfilter-${version}";

  version = "2.80";

  src = fetchzip {
    url = "http://gdlp01.c-wss.com/gds/1/0100000841/01/cnijfilter-common-2.80-1.tar.gz";
    sha256 = "06s9nl155yxmx56056y22kz1p5b2sb5fhr3gf4ddlczjkd1xch53";
  };

  buildInputs = [ autoconf libtool automake
                  cups popt ];

  patches = [ ./patches/missing-include.patch ];

  postPatch = ''
    sed -i "s|/usr/lib/cups/backend|$out/lib/cups/backend|" backend/src/Makefile.am;
  '';

  configurePhase = ''
    cd libs
    ./autogen.sh --prefix=$out;

    cd ../cngpij
    ./autogen.sh --prefix=$out --enable-progpath=$out/bin;

    cd ../pstocanonij
    ./autogen.sh --prefix=$out --enable-progpath=$out/bin;

    cd ../backend
    ./autogen.sh --prefix=$out;
    cd ..;
  '';

  preInstall = ''
    mkdir -p $out/bin $out/lib/cups/filter $out/share/cups/model;
  '';

  postInstall = ''
    for pr in mp140 mp210 ip3500 mp520 ip4500 mp610; do
      cd ppd;
      ./autogen.sh --prefix=$out --program-suffix=$pr
      make clean;
      make;
      make install DESTDIR=$out;

      cd ../cnijfilter;
      ./autogen.sh --prefix=$out --program-suffix=$pr --enable-libpath=$out/lib/bjlib --enable-binpath=$out/bin;
      make clean;
      make;
      make install;

      cd ..;
    done;

    mkdir -p $out/lib/bjlib;
    for pr_id in 315 316 319 328 326 327; do
      install -c -m 755 $pr_id/database/* $out/lib/bjlib;
      install -c -s -m 755 $pr_id/libs_bin/*.so.* $out/lib;
    done;
  '';

  meta = with lib; {
    description = "Canon InkJet printer drivers for the MX700 etc.";
    homepage = "http://support-asia.canon-asia.com/content/EN/0100084101.html";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jerith666 ];
  };
}
