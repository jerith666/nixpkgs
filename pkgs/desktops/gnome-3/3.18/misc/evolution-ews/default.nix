{ stdenv, fetchgit, gnome3 } :

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

  buildInputs = [ gnome3.gnome-common ];

  buildPhase = ''
    ./autogen.sh;
    buildPhase
  '';
}