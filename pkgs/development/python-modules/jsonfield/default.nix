{ stdenv, fetchPypi, buildPythonPackage, django, pytestCheckHook, pytest-django }:

buildPythonPackage rec {
  pname = "jsonfield";
  version = "1.0.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-fn9zpnXFGHErrdeDJ54m0WQUDz/C7XoyECw9CKaipKc=";
  };

  checkInputs = [ pytestCheckHook pytest-django ];

  preCheck = "export DJANGO_SETTINGS_MODULE=tests.settings";

  doCheck = false;

  propagatedBuildInputs = [ django ];

  meta = with stdenv.lib; {
    description = "Reusable model field that allows you to store validated JSON, automatically handling serialization to and from the database";
    homepage = "https://github.com/rpkilby/jsonfield/";
    license = licenses.mit;
    maintainers = with maintainers; [ mrmebelman ];
  };
}
