{ stdenv, fetchFromGitHub, python, pkgconfig, cmake, bluez, libusb1, curl
, libiconv, gettext, sqlite
, dbiSupport ? false, libdbi ? null, libdbiDrivers ? null
, postgresSupport ? false, postgresql ? null
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "gammu-${version}";
  version = "1.37.91";

  src = fetchFromGitHub {
    owner = "gammu";
    repo = "gammu";
    rev = "49b0b19f59c740817a9582303b8814d8488dc725";
    sha256 = "0nxb4k1lfsmfiricjfnyx5wdmw84sj3skxrsdkvrbimz2kz0qzs6";
  };

  patches = [ ./bashcomp-dir.patch ./systemd.patch ];

  buildInputs = [ python pkgconfig cmake bluez libusb1 curl gettext sqlite libiconv ]
  ++ optionals dbiSupport [ libdbi libdbiDrivers ]
  ++ optionals postgresSupport [ postgresql ];

  enableParallelBuilding = true;

  meta = {
    homepage = "http://wammu.eu/gammu/";
    description = "Command line utility and library to control mobile phones";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.coroa ];
  };
}
