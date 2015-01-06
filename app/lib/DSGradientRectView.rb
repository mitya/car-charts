class DSGradientRectView < UIView  
  attr_accessor :colors
  
  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()    
    colors = @colors || self.class.defaultColors
    KK.drawRect bounds, inContext:context, withGradientColors:colors, cornerRadius:2.0
  end
  
  def colors=(array)
    @colors = array
    setNeedsDisplay
  end
  
  def self.defaultColors
    @defaultColors ||= [KK.rgb(120,   2,   2), KK.rgb(153,  63,  63)].reverse
  end
end