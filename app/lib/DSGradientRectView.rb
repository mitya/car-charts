class DSGradientRectView < UIView  
  attr_accessor :colors
  
  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()    
    colors = @colors || self.class.defaultColors
    ES.drawRect bounds, inContext:context, withGradientColors:colors, cornerRadius:2.0
  end
  
  def colors=(array)
    @colors = array
    setNeedsDisplay
  end
  
  def self.defaultColors
    @defaultColors ||= [ES.rgb(120,   2,   2), ES.rgb(153,  63,  63)].reverse
  end
end