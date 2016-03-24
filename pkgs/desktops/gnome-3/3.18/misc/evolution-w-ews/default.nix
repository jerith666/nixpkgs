{ lib, pkgs, buildFHSUserEnv }:

buildFHSUserEnv {
  name = "evolution-w-ews";

  targetPkgs = pkgs: with pkgs;
                     ( [ pkgconfig gtk3 glib intltool itstool libxml2 libtool
                  gdk_pixbuf gnome3.defaultIconTheme librsvg db icu
                  gnome3.evolution_data_server libsecret libical #gcr
                  webkitgtk shared_mime_info gnome3.gnome_desktop gtkspell3
                  libcanberra_gtk3 bogofilter gnome3.libgdata sqlite
                  gst_all_1.gstreamer gst_all_1.gst-plugins-base p11_kit
                  nss nspr libnotify procps highlight gnome3.libgweather
                  gnome3.gsettings_desktop_schemas makeWrapper ] )
                  ++ ( [ dbus.tools ] )
                  ++ (with gnome3; [ evolution_data_server
                                     evolution
                                     evolution-ews ]);

  #runScript = "evolution";
  runScript = "bash";
}
