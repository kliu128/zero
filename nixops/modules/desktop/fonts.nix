{ config, lib, pkgs, ... }:

{
  # Fonts
  fonts.fontconfig.allowBitmaps = false;
  fonts.fonts = with pkgs; [
    # FA for Waybar
    font-awesome_5
    # Microsoft replacements
    carlito caladea comic-neue liberation_ttf liberationsansnarrow
    
    # Emoji
    twemoji-color-font 
    
    # Terminal fonts
    fira-code powerline-fonts
    
    # CJK support
    source-han-serif-simplified-chinese source-han-serif-japanese source-han-serif-korean source-han-serif-traditional-chinese
  ];
  fonts.fontconfig.penultimate.enable = false;
  fonts.fontconfig.localConf = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <!-- Replace Comic Sans with Comic Neue bold -->
      <match>
        <test name="family">
          <string>Comic Sans MS</string>
        </test>
        <edit binding="same" mode="assign" name="family">
          <string>Comic Neue</string>
        </edit>
        <edit binding="weak" mode="assign" name="style">
          <string>Bold</string>
        </edit>
      </match>
    </fontconfig>
  '';
}
