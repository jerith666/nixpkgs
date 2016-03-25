{ lib, pkgs, buildFHSUserEnv }:

let

  allInputs = p: p.buildInputs ++
                 builtins.concatLists (map allInputs p.buildInputs)

in

buildFHSUserEnv {
  name = "evolution-w-ews";

  targetPkgs = allInputs gnome3.evolution-ews;

  #runScript = "evolution";
  runScript = "bash";
}
