{ stdenv, lib, buildGoModule, fetchFromGitHub, fetchpatch, installShellFiles, makeWrapper
, nixosTests, rclone }:

buildGoModule rec {
  pname = "restic";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "restic";
    repo = "restic";
    rev = "v${version}";
    sha256 = "0nrh52cjymzcf093sqqa3kfw2nimnx6qwn8aw0wsci2v2r84yzzx";
  };

  vendorSha256 = "1pfixq3mbfn12gyablc4g0j8r00md3887q0l8xgxy76z0d8w924s";

  patches = [ ( fetchpatch {
    # https://github.com/restic/restic/issues/2571
    url = "https://github.com/MichaelEischer/restic/commit/c76b7588cc53a53fdc1fad06b66a39beb2e90b3c.patch";
    sha256 = "0g23dh0617fmj6l8n9nzxlyc6b5x69r0rldnl3xmwrsmr75dfgar";
  } ) ];

  subPackages = [ "cmd/restic" ];

  nativeBuildInputs = [ installShellFiles makeWrapper ];

  passthru.tests.restic = nixosTests.restic;

  postPatch = ''
    rm cmd/restic/integration_fuse_test.go
  '';

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
