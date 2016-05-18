{ stdenv, fetchurl, makeWrapper, perl, perlPackages }:

let
  version = "1.1.29";

in

stdenv.mkDerivation {
  name = "bins-${version}";

  src = fetchurl {
    url = "http://download.gna.org/bins/bins-${version}.tar.gz";
    sha256 = "0n4pcssyaic4xbk25aal0b3g0ibmi2f3gpv0gsnaq61sqipyjl94";
  };

  buildInputs = with perlPackages; [ makeWrapper perl
                                     ImageSize ImageInfo PerlMagick
                                     URI HTMLParser HTMLTemplate HTMLClean
                                     XMLGrove XMLHandlerYAWriter
                                     TextIconv TextUnaccent
                                     DateTimeFormatDateParse ];

  installPhase = ''
    export DESTDIR=$out;
    export PREFIX=.;

    echo | ./install.sh

    for f in bins bins_edit bins-edit-gui; do
      substituteInPlace $out/bin/$f --replace /usr/bin/perl ${perl}/bin/perl;
      wrapProgram $out/bin/$f --set PERL5LIB "$PERL5LIB";
    done
  '';

  meta = {
    description = "generates static HTML photo albums";
    homepage = http://bins.sautret.org;
  };
}