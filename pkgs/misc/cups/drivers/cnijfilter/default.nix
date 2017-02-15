# { stdenv, lib, fetchzip, autoconf, automake, cups, glib, libxml2, libusb, libtool
# , withDebug ? false }:

{ stdenv, lib, fetchurl,
  autoconf, automake, libtool, rpm,
  cups, popt }:

stdenv.mkDerivation rec {
  name = "cnijfilter-${version}";

  version = "2.80";

  src = fetchurl {
    url = "http://gdlp01.c-wss.com/gds/1/0100000841/01/cnijfilter-common-2.80-1.tar.gz";
    sha256 = "1qb4kwi1j86vj0cr0rx71avks8x5nbzzlc5gykcc3pyfrz4malqp";
  };

  buildInputs = [ autoconf libtool automake
                  cups popt rpm ];

  patches = [ ./patches/missing-include.patch ];

  postPatch = ''
    sed -i "s|/usr/lib/cups/backend|$out/lib/cups/backend|" backend/src/Makefile.am;
  '';

  buildPhase = ''
    echo build phase;
    pwd;
    ls -al;
    mkdir -pv rpmbuild/SOURCES;
    cp -iv $src rpmbuild/SOURCES/cnijfilter-common-2.80-1.tar.gz;
    rpmbuild --define '_topdir rpmbuild' -bi cnijfilter-common.spec;
  '';

  meta = with lib; {
    description = "Canon InkJet printer drivers for the MX700 etc.";
    homepage = "http://support-asia.canon-asia.com/content/EN/0100084101.html";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jerith666 ];
  };
}
