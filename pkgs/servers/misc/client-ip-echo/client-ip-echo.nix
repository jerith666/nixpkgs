{ mkDerivation, fetchFromGitHub, base, bytestring, network, stdenv }:
mkDerivation {
  pname = "client-ip-echo";
  version = "0.1.0.0";
  src = fetchFromGitHub {
    owner = "jerith666";
    repo = "client-ip-echo";
    rev = "748de215f39ee7de7bf6692f5e285602f0f3ba08";
    sha256 = "1psg5lwmi094jfs5wyn8w0fyv1mhs75spk3kr9hfbclc2qniwiww";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base bytestring network ];
  description = "accepts TCP connections and echoes the client's IP address back to it";
  license = stdenv.lib.licenses.lgpl3;
}
