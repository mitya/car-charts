module KK::Colors
  def rgb(red, green, blue, alpha = 1.0)
    UIColor.colorWithRed(red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
  end

  def rgbf(r, g, b, a = 1.0)
    UIColor.colorWithRed(r, green:g, blue:b, alpha:a)
  end

  def hsb(h, s, v, a = 1.0)
    UIColor.colorWithHue(h / 360.0, saturation: s / 100.0,  brightness: v / 100.0, alpha: a)
  end

  def grayShade(level)
    UIColor.colorWithWhite(level, alpha:1.0)
  end

  def hex(value)
    r = value >> 16 & 0xFF
    g = value >> 8 & 0xFF
    b = value & 0xFF
    rgb(r, g, b)
  end 

  def colorize(color)
    return color if color.is_a?(UIColor)
    return UIColor.send("#{color}Color") if color.is_a?(String) || color.is_a?(Symbol)
    return color
  end

  def patternColor(imageName)
    UIColor.colorWithPatternImage(KK.image(imageName))
  end
  
  def blueTextColor
    rgb(81, 102, 145)
  end
  
  def grayTextColor
    grayShade(0.5)
  end
  
  def separatorColor
    grayShade(0.8)
  end
  
  def tableViewFooterColor
    KK.rgbf(0.298, 0.337, 0.424)
  end
  
  def checkedTableViewItemColor
    KK.rgbf(0.22, 0.33, 0.53)
  end
end

KK.extend(KK::Colors)