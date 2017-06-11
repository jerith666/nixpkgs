{ stdenv, fetchurl, lib }:
{ version, artifactId, groupId, sha512, type ? "jar", suffix ? "", classifier ? null }:

let
  name = "${artifactId}-${version}";
  m2Path = "${builtins.replaceStrings ["."] ["/"] groupId}/${artifactId}/${version}" + (lib.optionalString (classifier != null) "-${classifier}");
  m2File = "${name}${suffix}.${type}";
  src = fetchurl rec {
      inherit sha512;
      url = "mirror://maven/${m2Path}/${m2File}";
  };
in stdenv.mkDerivation rec {
  inherit name m2Path m2File src;

  installPhase = ''
    mkdir -p $out/m2/$m2Path
    cp $src $out/m2/$m2Path/$m2File
  '';

  phases = "installPhase";
}
