{ fetchurl
, lib
, appimageTools
} :

let
  pname = "around";
  #when a required update is published, the launcher will fail
  #and output a line like:
  #desktopapp:updater Updater state changed:  {"type":"available","version":"0.54.8","downloadProgress":0,"isRequired":true} +118ms
  version = "0.64.51";

  src = fetchurl {
    url = "https://downloads.around.co/Around-${version}.AppImage";
    hash = "sha256-+h621GQx6H7wy+dEWi3RRPXOr7NUvXf9LfP/RXaPdhI=";
  };

  appimageContents = appimageTools.extract { inherit pname src version; };

in

appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop \
      -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' "Exec=$out/bin/${pname}"
    cp -vr ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "Video calls loved by extraordinary teams";
    homepage = "https://www.around.co/";
    license = licenses.unfree;
  };
}
