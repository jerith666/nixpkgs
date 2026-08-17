{
  lib,
  fetchpatch,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "getmail6";
  version = "6.20.00";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "getmail6";
    repo = "getmail6";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f0IH0wI7Ue/HjvMIhBRGaMoO9BYDJoH/3fWRDsFD9+8=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  # needs a Docker setup
  doCheck = false;

  pythonImportsCheck = [ "getmailcore" ];

  patches = [
    # https://github.com/getmail6/getmail6/issues/276
    (fetchpatch {
      url = "https://github.com/getmail6/getmail6/commit/a9bfaf5aa4e6f9077c7c2f16332521e83a19b5c2.patch";
      hash = "sha256-L7zJn/aIJYI/7JYuhzS1lpiG4ZGnvB7NANEMN9twlTs=";
    })
    (fetchpatch {
      url = "https://github.com/getmail6/getmail6/commit/809b0f3b1ad9d980b7cd4aacb200cc581b9514d2.patch";
      hash = "sha256-quBI95L9iWTz5umMe8agn+OCVNltL+N9Xw9PTQIMucE=";
    })
  ];

  postPatch = ''
    # getmail spends a lot of effort to build an absolute path for
    # documentation installation; too bad it is counterproductive now
    sed -e '/datadir or prefix,/d' -i setup.py
    sed -e 's,/usr/bin/getmail,$(dirname $0)/getmail,' -i getmails
  '';

  meta = {
    description = "Program for retrieving mail";
    homepage = "https://getmail6.org";
    changelog = "https://github.com/getmail6/getmail6/blob/${finalAttrs.src.tag}/docs/CHANGELOG";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      abbe
      dotlambda
    ];
  };
})
