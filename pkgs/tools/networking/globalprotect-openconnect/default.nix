{ stdenv, fetchFromGitHub,
  qmake,
  qtwebsockets, qtwebengine,
  openconnect } :

stdenv.mkDerivation rec {
  name = "globalprotect-openconnect-${version}";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    fetchSubmodules = true;
    rev = "c14a6ad1d2b62f8d297bc4cfbcb1dcea4d99112f";
    sha256 = "1zkc3vk1j31n2zs5ammzv23dah7x163gfrzz222ynbkvsccrhzrk";
  };

  nativeBuildInputs = [ qmake ];

  buildInputs = [ openconnect
                  qtwebsockets qtwebengine ];

  patchPhase = ''
    for f in GPClient/GPClient.pro \
             GPClient/com.yuezk.qt.gpclient.desktop \
             GPService/GPService.pro \
             GPService/dbus/com.yuezk.qt.GPService.service \
             GPService/systemd/gpservice.service; do
        substituteInPlace $f --replace /usr $out;
        substituteInPlace $f --replace /etc $out/lib;
    done;

    substituteInPlace GPService/gpservice.h \
      --replace /usr/local/bin/openconnect ${openconnect}/bin/openconnect;
  '';

  meta = with stdenv.lib; {
    description = "A GlobalProtect VPN client (GUI) for Linux based on OpenConnect and built with Qt5, supports SAML auth mode.";
    homepage = "https://github.com/yuezk/GlobalProtect-openconnect";
    license = licenses.gpl3;
    maintainers = [ maintainers.jerith666 ];
    platforms = platforms.linux;
  };
}
