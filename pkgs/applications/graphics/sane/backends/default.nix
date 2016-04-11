{ callPackage, fetchurl, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "1.0.24";
  src = fetchurl {
    sha256 = "0ba68m6bzni54axjk15i51rya7hfsdliwvqyan5msl7iaid0iir7";
    urls = [
      "http://pkgs.fedoraproject.org/repo/pkgs/sane-backends/sane-backends-${version}.tar.gz/1ca68e536cd7c1852322822f5f6ac3a4/sane-backends-${version}.tar.gz"
      "https://alioth.debian.org/frs/download.php/file/3958/sane-backends-${version}.tar.gz"
    ];
    curlOpts = "--insecure";
  };
})
