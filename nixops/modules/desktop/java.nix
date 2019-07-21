{ config, lib, pkgs, ... }:

# Java runtime and development

let
  jdk = pkgs.adoptopenjdk-openj9-bin-11;
in {
  # Use GTK theme, enable antialiasing
  environment.variables._JAVA_OPTIONS = ''
    -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel
    -Dawt.useSystemAAFontSettings=on
  '';
  programs.java = {
    enable = true;
    package = jdk;
  };

  # Alias so IntelliJ knows where Java is located
  environment.etc.intellij-jdk.source = pkgs.jetbrains.jdk;
  environment.etc.system-jdk.source = jdk;

  # Install IntelliJ
  environment.systemPackages = with pkgs; [ jetbrains.idea-community ];
}
