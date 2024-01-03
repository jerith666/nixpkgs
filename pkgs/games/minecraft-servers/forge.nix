{ lib
, stdenv
, pkgs
, jre_headless
, rsync
, bash
, version
, installerJarHash
, installerResultHash
}:

let
  forgeInstall = stdenv.mkDerivation {
    pname = "forge-install";
    inherit version;

    # the forge project requests that download of their installer not be automated
    src = pkgs.requireFile {
      name = "forge-${version}-installer.jar";
      url = "https://files.minecraftforge.net/";
      sha256 = installerJarHash;
    };

    dontUnpack = true;

    buildInputs = [ jre_headless ];

    installPhase = ''
      mkdir -p $out;
      cd $out;
      java -jar $src --installServer;

      # fixed-output derivations are not permitted to refer to store paths
      # (otherwise I guess they're not really fixed-output, are they?)
      # if they do, they produce the somewhat obtuse error:
      # illegal path references in fixed-output derivation

      # the log file references the store path of the jdk and such
      rm -v *-installer.jar.log;

      # this shell script has its interpreter path patched to refer to
      # the copy of bash in the store; avoid that
      grep -v '^#!' run.sh > run.sh.tmp;
      mv -vf run.sh.tmp run.sh;
    '';

    outputHash = installerResultHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

in

stdenv.mkDerivation {
  pname = "forge";
  inherit version;

  src = forgeInstall;

  buildInputs = [ jre_headless rsync bash ];

  startupScript = pkgs.writeScript "minecraft-server" ''
    #!${bash}/bin/sh

    # vanilla server does this automagically; forge does not
    ${rsync}/bin/rsync -avP ${forgeInstall}/libraries/ libraries;

    exec ${jre_headless}/bin/java @libraries/net/minecraftforge/forge/${version}/unix_args.txt "\$@"
  '';

  installPhase = ''
    mkdir -p $out/bin;

    cd $out/bin;
    ln -s $startupScript minecraft-server;
  '';

  meta = {
    description = "Modifications to the Minecraft base files to assist in compatibility between mods";
    homepage = "https://minecraftforge.net/";
    license = lib.licenses.lgpl21;
  };
}
