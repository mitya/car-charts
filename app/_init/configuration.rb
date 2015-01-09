module Configuration
  module_function
  
  def tintColor
    KK.hsb(30, 100, 60)
  end
  
  def barTintColor
    KK.hsb(30, 100, 25)
  end
  
  def barIconColor
    KK.hsb(30, 30, 85)
  end
  
  def barTextColor
    :white.uicolor
  end
end
