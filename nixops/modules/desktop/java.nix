{ config, lib, pkgs, ... }:

# Java runtime and development

let
  jdk = pkgs.jdk14;
in {
  # Use GTK theme, enable antialiasing
  home-manager.users.kevin.home.sessionVariables._JAVA_OPTIONS = ''
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

  # Install Java editors
  environment.systemPackages = with pkgs; [ eclipses.eclipse-sdk jetbrains.idea-community maven ];

  # Use light theme for Eclipse (see: Gracia)
  home-manager.users.kevin.home.file.".local/share/applications/Eclipse.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=env GTK_THEME=Adwaita eclipse
    Terminal=false
    Name=Eclipse IDE
    Categories=Application;Development;
    Icon=eclipse
    Comment=Integrated Development Environment
    GenericName=Integrated Development Environment
  '';
}
