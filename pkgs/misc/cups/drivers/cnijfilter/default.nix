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
    for dir in libs cngpij pstocanonij backend; do
      cd $dir;
      ./autogen.sh --prefix=$out;
      cd ..;
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
