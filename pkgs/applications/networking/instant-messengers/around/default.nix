{ fetchurl
, appimageTools
} :

let
  name = "around";

  src = fetchurl {
    url = "https://downloads.around.co/Around.AppImage";
    sha256 = "1wq0jz8b1g9ahcjxqj33ng37jycqikc502dj91yq6cs30gcps34b";
  };

  appimageContents = appimageTools.extract { inherit name src; };

in

appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${name}.desktop \
      -t $out/share/applications
    substituteInPlace $out/share/applications/${name}.desktop \
      --replace 'Exec=AppRun' "Exec=$out/bin/${name}"
    cp -vr ${appimageContents}/usr/share/icons $out/share
  '';
}
