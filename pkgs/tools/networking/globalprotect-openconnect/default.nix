{ stdenv
, lib
, fetchurl
, rustPlatform
, perl
, qtwebsockets
, qtwebengine
, qtkeychain
, wrapQtAppsHook
, openconnect
}:

rustPlatform.buildRustPackage rec {
  pname = "globalprotect-openconnect";
  version = "2.3.3";

  src = fetchurl {
    url = "https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v${version}/globalprotect-openconnect-${version}.tar.gz";
    hash = "sha256-HwVXKz36VzIYNwmbRekZI6qmWyagbZkHcCk1ObA5D1I=";
  };

  nativeBuildInputs = [ perl wrapQtAppsHook ];

  buildInputs = [ openconnect qtwebsockets qtwebengine qtkeychain ];

  cargoHash = "sha256-LubGbTSIr/REqfOzCJe0ElnjELOA5H3N3Ng+lImGrtA=";

  INCLUDE_GUI = 0;
  BUILD_FE = 0;

  meta = with lib; {
    description = "GlobalProtect VPN client (GUI) for Linux based on OpenConnect that supports SAML auth mode";
    homepage = "https://github.com/yuezk/GlobalProtect-openconnect";
    license = licenses.gpl3Only;
    maintainers = [ maintainers.jerith666 ];
    platforms = platforms.linux;
  };
}
