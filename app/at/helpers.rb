module Helper
  module_function
  
  # Drawing

  def drawGradientRect(context, rect, colors)
    # locationsPtr = Pointer.new(:float, 2)
    # locationsPtr[0] = 0.0
    # locationsPtr[1] = 1.0

    colorSpace = CGColorSpaceCreateDeviceRGB()
    # colors = [color1.CGColor, color2.CGColor, Helper.rgb(255, 102, 102).CGColor]
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

  # Geometry

  def rectWithChangedWidth(rect, widthDelta)
    CGRectMake(rect.x, rect.y, rect.width + widthDelta, rect.height)
  end

  # Colors
  
  def rgb(red, green, blue, alpha = 1.0)
    UIColor.colorWithRed(red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
  end

  def rgbf(r, g, b, a = 1.0)
    UIColor.colorWithRed(r, green:g, blue:b, alpha:a)
  end
  
  def grayShade(level)
    rgbf(level, level, level, 1.0)
  end

  def hex(value)
    r = value >> 16 & 0xFF
    g = value >> 8 & 0xFF
    b = value & 0xFF
    rgb(r, g, b)
  end 
  
  # Other
  
  def benchmark(actionName = "Action", &block)
    startTime = Time.now
    block.call
    elapsed = (Time.now - startTime) * 1_000
    NSLog "@time #{actionName}: #{"%.3f" % elapsed}ms"
  end
end

Hel = Helper

module Color  
  def self.method_missing(selector, *args)
    if UIColor.respond_to?("#{selector}Color")
      UIColor.send("#{selector}Color")
    else
      super
    end
  end
end
