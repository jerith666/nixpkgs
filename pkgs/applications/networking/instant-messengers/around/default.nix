{ fetchurl
, appimageTools
} :

let
  name = "around";
  #when a required update is published, the launcher will fail
  #and output a line like:
  #desktopapp:updater Updater state changed:  {"type":"available","version":"0.54.8","downloadProgress":0,"isRequired":true} +118ms
  version = "0.54.8";

  src = fetchurl {
    url = "https://downloads.around.co/Around-${version}.AppImage";
    sha256 = "0szdnw5q41msbsjbfd9v4rcrsdgq710a9l5maa944mbymjz2rvjw";
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
