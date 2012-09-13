module Helper
  module_function
  
  def drawGradientRect(context, rect, colors)
    # locationsPtr = Pointer.new(:float, 2)
    # locationsPtr[0] = 0.0
    # locationsPtr[1] = 1.0

    colorSpace = CGColorSpaceCreateDeviceRGB()
    # colors = [color1.CGColor, color2.CGColor, Helper.rgbColor(255, 102, 102).CGColor]
    # colors = colors.map(&:CGColor)
    colors = colors.map { |c| c.CGColor }
    gradient = CGGradientCreateWithColors(colorSpace, colors, nil)
    
    startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
    endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
 
    path = UIBezierPath.bezierPathWithRoundedRect(rect, 
      byRoundingCorners: UIRectCornerAllCorners, # UIRectCornerTopRight | UIRectCornerBottomRight, 
      cornerRadii: CGSizeMake(2,2)
    )
     
    CGContextSaveGState(context)
    path.addClip
    CGContextClip(context) unless CGContextIsPathEmpty(context)
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)
    CGContextRestoreGState(context)
 
    # CGGradientRelease(gradient)
    # CGColorSpaceRelease(colorSpace)    
  end  

  def drawStringInRect(string, rect, color, font, lineBreakMode, alignment)
    color.set
    font = UIFont.systemFontOfSize(font) if font.is_a?(Numeric)
    string.drawInRect rect, withFont:font, lineBreakMode:lineBreakMode, alignment:alignment
  end  
  
  def rgbColor(red, green, blue)
    UIColor.colorWithRed(red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
  end  
  
  def rectWithChangedWidth(rect, widthDelta)
    CGRectMake(rect.x, rect.y, rect.width + widthDelta, rect.height)
  end
  
  def benchmark(actionName = "Action", &block)
    startTime = Time.now
    block.call
    elapsed = (Time.now - startTime) * 1_000
    NSLog "@time #{actionName}: #{"%.3f" % elapsed}ms"
  end
end

class CGRect
  def x
    origin.x
  end

  def y
    origin.y
  end

  def width
    size.width
  end

  def height
    size.height
  end
  
  def withXMargins(margin)
    CGRectMake(x + margin, y, width - margin * 2, height)
  end
end

def Point(x, y)
  CGPointMake(x, y)
end

def BoldSystemFont(size)
  UIFont.boldSystemFontOfSize(size)
end

def SystemFont(size)
  UIFont.systemFontOfSize(size)
end

module Color
  def self.hex(value)
    r = value >> 16 & 0xFF
    g = value >> 8 & 0xFF
    b = value & 0xFF
    self.rgbi(r, g, b)
  end
  
  def self.rgba(r, g, b, a)
    UIColor.colorWithRed(r, green:g, blue:b, alpha:a)
  end
  
  def self.rgbi(r, g, b)
    rgba(r / 255.0, g / 255.0, b / 255.0, 1)
  end
  
  def self.grayShade(level)
    rgba(level, level, level, 1)
  end
  
  def self.method_missing(selector, *args)
    if UIColor.respond_to?("#{selector}Color")
      UIColor.send("#{selector}Color")
    else
      super
    end
  end
end

def Color(colorName)
  UIColor.send("#{colorName}Color")
end

