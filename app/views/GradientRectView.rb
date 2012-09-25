class GradientRectView < UIView  
  attr_accessor :colors
  
  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()    
    colors = @colors || self.class.defaultColors
    Hel.drawGradientRect context, bounds, colors
  end
  
  def colors=(array)
    @colors = array
    setNeedsDisplay
  end
  
  def self.defaultColors
    @defaultColors ||= [Hel.rgb(120,   2,   2), Hel.rgb(153,  63,  63)].reverse
  end
end