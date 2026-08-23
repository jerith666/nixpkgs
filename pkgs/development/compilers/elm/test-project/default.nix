{
  stdenv,
  elmPackages,
  python3,
}:

let
  inherit (elmPackages)
    elm

    # known not to work with 0.19.1
    # https://github.com/stil4m/elm-analyse/issues/223
    # elm-analyse

    # does not work with 0.19.1
    # for unknown reasons
    # elm-doc-preview

    # would require a local git repo to clone
    # elm-git-install

    elm-format

    elm-graphql

    elm-json

    elm-language-server
    ;
in

stdenv.mkDerivation {
  name = "simple-elm-test-project";
  version = elm.version;

  src = ./.;

  dontUnpack = true;

  preBuild = elmPackages.fetchElmDeps {
    elmVersion = "0.19.1";
    elmPackages = import ./nix/elm-srcs.nix;
    registryDat = ./nix/registry.dat;
  };

  buildPhase = ''
    runHook preBuild

    # elm-application.json needed by elm-doc-preview
    cp -v $src/elm{,-application}.json .;
    cp -v $src/lsp-test.py .;
    mkdir src;
    cp -v $src/src/*.elm src/;
    chmod +w src/*.elm;

    # elm-json still uses a versions.dat file like 0.19.0
    # (hasn't migrated to a registry.dat like 0.19.1 yet)
    mkdir $ELM_HOME/elm-json;
    cp -v $src/nix/versions.dat $ELM_HOME/elm-json/versions.dat;
    chmod +w $ELM_HOME/elm-json/versions.dat;

    # --- some utils can run before the compiler

    # confirm that elm-format transforms the file as expected
    echo y | ${elm-format}/bin/elm-format src/Main.elm;
    echo "SHA256 (src/Main.elm) = hip2ZJfFoJ2S57cTa+jf8xHBavFECPSKUduMSTSGZxA=" | cksum --check

    cp -v $src/github-schema.json .;
    ${elm-graphql}/bin/elm-graphql --schema-file github-schema.json --skip-elm-format;
    rm -rf src/Api;

    ${elm-json}/bin/elm-json --offline tree;

    # --- here is the invocation of the compiler itself

    ${elm}/bin/elm make src/Main.elm;

    # --- a few need the results of the compiler to do their jobs

    PATH=${elm}/bin:''${PATH} ${python3}/bin/python lsp-test.py ${elm-language-server}/bin/elm-language-server $(pwd) | grep "Missing type annotation: .Html.Html msg"

    # TODO fix elm-doc-preview build to embed /nix/store/...-elm/bin/elm directly
    # even with the PATH fixed and an elm-application.json supplied, this does
    # not currently work
    # PATH=$PATH:${elm}/bin ''${elm-doc-preview}/bin/elm-doc-preview --debug --output doc-preview;

    touch $out;
  '';
}
