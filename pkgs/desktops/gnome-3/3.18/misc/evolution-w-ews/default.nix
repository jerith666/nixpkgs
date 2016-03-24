{ lib, pkgs, buildFHSUserEnv }:

buildFHSUserEnv {
  name = "evolution-w-ews";

  targetPkgs = pkgs: with pkgs; [ evolution-data-server,
                                  evolution,
                                  evoltion-ews ];

  runScript = "evolution";
}
