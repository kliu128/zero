{ config, lib, pkgs, ... }:

# Java runtime and development

let
  jdk = pkgs.openjdk11;
in {
  # Use GTK theme, enable antialiasing
  environment.variables._JAVA_OPTIONS = ''
    -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel
    -Dawt.useSystemAAFontSettings=on
    --module-path=${pkgs.openjfx}/lib
    --add-modules=javafx.controls,javafx.fxml,javafx.graphics,javafx.media,javafx.swing,javafx.web
  '';
  programs.java = {
    enable = true;
    package = jdk;
  };

  # Alias so IntelliJ knows where Java is located
  environment.etc."intellij-jdk".source = pkgs.jetbrains.jdk;

  # Install IntelliJ
  environment.systemPackages = with pkgs; [ jetbrains.idea-community eclipses.eclipse-sdk ];
}
