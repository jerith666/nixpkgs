{
  perl,
  jq,
  fetchFromGitHub,
  lib,
  openconnect,
  libsoup,
  webkitgtk_4_0,
  pkg-config,
  callPackage,
  rustPlatform,
  glib,
  atk,
  gdk-pixbuf,
  pango,
  cairo,
  harfbuzz,
  gtk3,
  zlib,
  makeDesktopItem,
  includeUnfreeGui ? false,
}:
let
  version = "2.3.7";
  pname = "globalprotect-openconnect";
  desktop = makeDesktopItem {
    name = "GlobalProtect Openconnect VPN Client";
    desktopName = "GlobalProtect Openconnect VPN Client";
    comment = "A GUI for GlobalProtect VPN";
    genericName = "GlobalProtect VPN Client";
    exec = "gpclient launch-gui %u";
    icon = "gpgui";
    categories = [
      "Network"
      "Dialup"
    ];
    mimeTypes = [ "x-scheme-handler/globalprotectcallback" ];
  };

  gpgui = if includeUnfreeGui then (callPackage ./gui.nix { }) else null;

in
rustPlatform.buildRustPackage {
  inherit version pname;

  src = fetchFromGitHub {
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    rev = "v${version}";
    hash = "sha256-Zr888II65bUjrbStZfD0AYCXKY6VdKVJHQhbKwaY3is=";
  };

  nativeBuildInputs = [
    perl
    jq
    openconnect
    libsoup
    webkitgtk_4_0
    pkg-config
  ];

  PKG_CONFIG_PATH = lib.strings.concatMapStringsSep ":" (pkg: "${pkg}/lib/pkgconfig/") [
    glib.dev
    libsoup.dev
    webkitgtk_4_0.dev
    atk.dev
    gdk-pixbuf.dev
    pango.dev
    cairo.dev
    harfbuzz.dev
    gtk3.dev
    openconnect
    zlib
  ];

  NIX_CFLAGS_COMPILE = (map (pkg: "-I${pkg}/include") [ openconnect.dev ]);

  NIX_CFLAGS_LINK = (
    map (pkg: "-L${lib.getLib pkg}/lib") [
      openconnect
      zlib
    ]
  );

  cargoHash = "sha256-cdhhBUQASrnfjeJxkwx39vr/KHeQlBh0wMvw+Q7EK98=";

  postPatch =
    let
      replacements = builtins.filter (v: v != null) [
        "/usr/bin/gpclient $out/bin/gpclient"
        "/usr/bin/gpservice $out/bin/gpservice"
        "/usr/bin/gpgui-helper $out/bin/gpgui-helper"
        "/usr/bin/gpauth $out/bin/gpauth"
        (if includeUnfreeGui then "/usr/bin/gpgui ${gpgui}/bin/gpgui" else null)
      ];
      replacements-string = lib.strings.concatMapStringsSep " " (l: "--replace-fail ${l}") replacements;
    in
    ''
      substituteInPlace crates/gpapi/src/lib.rs ${replacements-string}
    '';

  postInstall = ''
    mkdir -p $out/share/
    ln -s ${desktop}/share/applications/ $out/share/applications
  ''
  + (lib.strings.optionalString includeUnfreeGui ''
    ln -s ${gpgui}/bin/gpgui $out/bin/
    ln -s ${gpgui}/share/icons/ $out/share/
    ln -s ${gpgui}/share/polkit-1/ $out/share/
  '');

  meta = {
    mainProgram = "gpclient";
    description = "A GlobalProtect VPN client for Linux, written in Rust, based on OpenConnect and Tauri, supports SSO with MFA, Yubikey, and client certificate authentication, etc.";
    longDescription = ''
      This package packages both the executables for the cli version of
      globalprotect-openconnect_2 (gpclient and gpauth), and the executables
      for the gui version (same as before + gpservice and gpgui).
    '';

    license = with lib.licenses; if includeUnfreeGui then unfree else gpl3;

    homepage = "https://github.com/yuezk/GlobalProtect-openconnect";
    maintainers = with lib.maintainers; [
      m1dugh
      binary-eater
    ];
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
