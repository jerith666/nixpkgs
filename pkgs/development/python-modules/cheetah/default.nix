{ lib
, buildPythonPackage
, fetchPypi
, markdown
, isPy3k
, TurboCheetah
}:

buildPythonPackage rec {
  pname = "Cheetah3";
  version = "3.2.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ar5dqjnqaw0c17mymd6xgd81jn9br9fblawr0x438v1571bkaya";
  };

  propagatedBuildInputs = [ markdown ];

  doCheck = false; # Circular dependency

  checkInputs = [
    TurboCheetah
  ];

  meta = {
    homepage = http://www.cheetahtemplate.org/;
    description = "A template engine and code generation tool";
    license = lib.licenses.mit;
  };
}