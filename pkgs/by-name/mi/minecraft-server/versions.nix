{
  lib,
  pkgs,
  javaPackages,
  stdenv,
  fetchurl,
  nixosTests,
  makeWrapper,
  udev,
  bash,
  rsync,
}:
let
  versions = lib.importJSON ./versions.json;
  forgeVersions = lib.importJSON ./forge-versions.json;

  latestVersion = lib.last (builtins.sort lib.versionOlder (builtins.attrNames versions));
  latestForgeVersion = lib.last (builtins.sort lib.versionOlder (builtins.attrNames forgeVersions));

  escapeVersion = builtins.replaceStrings [ "." ] [ "-" ];

  getJavaVersion = v: (builtins.getAttr "openjdk${toString v}" javaPackages.compiler).headless;

  mkVersion = (
    version: value: {
      name = "vanilla-${escapeVersion version}";
      value = import ./derivation.nix {
        inherit
          lib
          stdenv
          fetchurl
          nixosTests
          makeWrapper
          udev
          ;
        inherit (value) version url sha1;
        jre_headless = getJavaVersion (
          if value.javaVersion == null then
            8
          else if value.javaVersion == 16 then
            17
          else
            value.javaVersion
        ); # versions <= 1.6 will default to 8
      };
    }
  );

  mkForgeVersion = (
    version: value: {
      name = "forge-${escapeVersion version}";
      value = import ./forge.nix {
        inherit
          lib
          pkgs
          stdenv
          bash
          rsync
          ;
        inherit (value) version installerJarHash installerResultHash;
        jre_headless = getJavaVersion (if value.javaVersion == null then 8 else value.javaVersion); # versions <= 1.6 will default to 8
      };
    }
  );

  packages = lib.mapAttrs' mkVersion versions;
  forgePackages = lib.mapAttrs' mkForgeVersion forgeVersions;
in
lib.recurseIntoAttrs (
  packages
  // forgePackages
  // {
    vanilla = (mkVersion latestVersion versions.${latestVersion}).value;

    forge = (mkVersion latestForgeVersion forgeVersions.${latestForgeVersion}.value);
  }
)
