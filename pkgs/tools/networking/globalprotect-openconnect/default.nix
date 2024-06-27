{ stdenv
, lib
, fetchurl
, qtwebsockets
, qtwebengine
, qtkeychain
, wrapQtAppsHook
, openconnect
}:

stdenv.mkDerivation rec {
  pname = "globalprotect-openconnect";
  version = "2.3.3";

  src = fetchurl {
    url = "https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v${version}/globalprotect-openconnect-${version}.tar.gz";
    hash = "sha256-HwVXKz36VzIYNwmbRekZI6qmWyagbZkHcCk1ObA5D1I=";
  };

  nativeBuildInputs = [ wrapQtAppsHook ];

  buildInputs = [ openconnect qtwebsockets qtwebengine qtkeychain ];

  meta = with lib; {
    description = "GlobalProtect VPN client (GUI) for Linux based on OpenConnect that supports SAML auth mode";
    homepage = "https://github.com/yuezk/GlobalProtect-openconnect";
    license = licenses.gpl3Only;
    maintainers = [ maintainers.jerith666 ];
    platforms = platforms.linux;
  };
}
