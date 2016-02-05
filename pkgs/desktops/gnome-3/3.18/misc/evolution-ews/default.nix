{ stdenv, fetchgit, gnome3, glib, intltool, pkgconfig, gtk_doc, libtool, gtk3, libsoup, sqlite, webkitgtk24x, libmspack } :

let
  version = "3.18.4";

in

stdenv.mkDerivation {
  name = "evolution-ews-${version}";

  src = fetchgit {
    url = "git://git.gnome.org/evolution-ews";
    rev = "10b88536a04d32f26ede3c412d583054d7dac2c9";
    sha256 = "1hi6n9mii98s4dbzilpq59hcbj20mcpzy3wwxj3sh0njjks68l8r";
  };

  buildInputs = [ gnome3.gnome_common gnome3.evolution_data_server gnome3.evolution
                  glib intltool pkgconfig gtk_doc libtool gtk3 libsoup sqlite webkitgtk24x libmspack ];

  patches = [ ./lib-install.patch ];

  preConfigure = ''
    ./autogen.sh --prefix=$out;
  '';
}