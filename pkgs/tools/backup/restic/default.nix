{ stdenv, lib, buildGoPackage, fetchFromGitHub, fetchpatch, installShellFiles, makeWrapper
, nixosTests, rclone }:

buildGoPackage rec {
  pname = "restic";
  version = "0.9.6";

  goPackagePath = "github.com/restic/restic";

  src = fetchFromGitHub {
    owner = "restic";
    repo = "restic";
    rev = "v${version}";
    sha256 = "0lydll93n1lcn1fl669b9cikmzz9d6vfpc8ky3ng5fi8kj3v1dz7";
  };

  patches = [ ( fetchpatch {
    # https://github.com/restic/restic/issues/2571
    url = "https://github.com/MichaelEischer/restic/commit/c76b7588cc53a53fdc1fad06b66a39beb2e90b3c.patch";
    sha256 = "0g23dh0617fmj6l8n9nzxlyc6b5x69r0rldnl3xmwrsmr75dfgar";
  } ) ];

  subPackages = [ "cmd/restic" ];

  nativeBuildInputs = [ installShellFiles makeWrapper ];

  passthru.tests.restic = nixosTests.restic;

  postInstall = ''
    wrapProgram $out/bin/restic --prefix PATH : '${rclone}/bin'
  '' + lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
    $out/bin/restic generate \
      --bash-completion restic.bash \
      --zsh-completion restic.zsh \
      --man .
    installShellCompletion restic.{bash,zsh}
    installManPage *.1
  '';

  meta = with lib; {
    homepage = "https://restic.net";
    description = "A backup program that is fast, efficient and secure";
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.bsd2;
    maintainers = [ maintainers.mbrgm ];
  };
}
