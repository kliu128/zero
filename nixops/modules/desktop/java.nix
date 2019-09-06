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

  # Easy aliases for different java versions
  environment.etc."jdks/system".source = jdk;
  environment.etc."jdks/intellij".source = pkgs.jetbrains.jdk;
  environment.etc."jdks/java8".source = pkgs.openjdk8;

  # Install IntelliJ
  environment.systemPackages = with pkgs; [ eclipses.eclipse-sdk jetbrains.idea-community ];
}
