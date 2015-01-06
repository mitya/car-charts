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
end

KK.extend(KK::Fonts)