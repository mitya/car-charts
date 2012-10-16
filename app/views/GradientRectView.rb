class GradientRectView < UIView  
  attr_accessor :colors
  
  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()    
    colors = @colors || self.class.defaultColors
    ES.drawGradientRect context, bounds, colors
  end
  
  def colors=(array)
    @colors = array
    setNeedsDisplay
  end
  
  def self.defaultColors
    @defaultColors ||= [ES.rgb(120,   2,   2), ES.rgb(153,  63,  63)].reverse
  end
end