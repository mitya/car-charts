module KK::Fonts
  def fontize(font)
    return font if font.is_a?(UIFont)
    return UIFont.systemFontOfSize(font) if font.is_a?(Numeric)
    return font
  end
  
  def mainFont(size)
    UIFont.systemFontOfSize(size)
  end    
  
  def boldFont(size)
    UIFont.boldSystemFontOfSize(size)
  end

  FontLineHeights = { 
    6.0 => 8.0, 6.5 => 9.0, 7.0 => 10.0, 7.5 => 10.0, 8.0 => 11.0, 8.5 => 11.0, 9.0 => 12.0, 9.5 => 13.0, 10.0 => 13.0, 10.5 => 14.0,
    11.0 => 14.0, 11.5 => 14.0, 12.0 => 15.0, 12.5 => 15.0, 13.0 => 16.0, 13.5 => 18.0, 14.0 => 18.0, 14.5 => 19.0, 15.0 => 19.0,
    15.5 => 19.0, 16.0 => 20.0, 16.5 => 20.0, 17.0 => 21.0, 17.5 => 22.0, 18.0 => 22.0, 18.5 => 23.0, 19.0 => 23.0, 19.5 => 24.0,
    20.0 => 24.0, 20.5 => 25.0, 21.0 => 26.0, 21.5 => 26.0, 22.0 => 27.0, 22.5 => 28.0, 23.0 => 28.0, 23.5 => 29.0, 24.0 => 29.0, 24.5 => 29.0,
  }

  def lineHeightFromFontSize(size)
    FontLineHeights[size.to_f]
  end
end

KK.extend(KK::Fonts)
