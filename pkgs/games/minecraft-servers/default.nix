{ callPackage, lib, javaPackages }:
let
  versions = lib.importJSON ./versions.json;
  forgeVersions = lib.importJSON ./forge-versions.json;

  latestVersion = lib.last (builtins.sort lib.versionOlder (builtins.attrNames versions));
  latestForgeVersion = lib.last (builtins.sort lib.versionOlder (builtins.attrNames forgeVersions));

  escapeVersion = builtins.replaceStrings [ "." ] [ "-" ];

  getJavaVersion = v: (builtins.getAttr "openjdk${toString v}" javaPackages.compiler).headless;

  packages = lib.mapAttrs'
    (version: value: {
      name = "vanilla-${escapeVersion version}";
      value = callPackage ./derivation.nix {
        inherit (value) version url sha1;
        jre_headless = getJavaVersion (
          if value.javaVersion == null then 8
          else if value.javaVersion == 16 then 17
          else value.javaVersion
        ); # versions <= 1.6 will default to 8
      };
    })
    versions;

  forgePackages = lib.mapAttrs'
    (version: value: {
      name = "forge-${escapeVersion version}";
      value = callPackage ./forge.nix {
        inherit (value) version installerJarHash installerResultHash;
        jre_headless = getJavaVersion (if value.javaVersion == null then 8 else value.javaVersion); # versions <= 1.6 will default to 8
      };
    })
    forgeVersions;
in
lib.recurseIntoAttrs (
  packages // forgePackages // {
    vanilla = builtins.getAttr "vanilla-${escapeVersion latestVersion}" packages;

    forge = builtins.getAttr "forge-${escapeVersion latestForgeVersion}" forgePackages;
  }
)
