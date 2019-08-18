{ lib, pkgs }:

mkDerivation {
  name = "buildenv-test";
  builder = ''
    echo true;
  '';
}