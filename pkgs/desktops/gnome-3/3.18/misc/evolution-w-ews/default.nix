{ lib, buildFHSUserEnv }:

let

  allInputs = p: if (builtins.isAttrs p && builtins.hasAttr "nativeBuildInputs" p)
                    then (p.nativeBuildInputs ++
                          (builtins.concatLists (map allInputs p.nativeBuildInputs)))
                    else [];

in

buildFHSUserEnv {
  name = "evolution-w-ews";

  targetPkgs = pkgs: [pkgs.dbus.tools] ++ (allInputs pkgs.gnome3.evolution-ews);

  #runScript = "evolution";
  runScript = "bash";
}
