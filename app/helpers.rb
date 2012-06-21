module Helper
  module_function
  
  def drawGradientRect(context, rect, color1, color2)
    # locationsPtr = Pointer.new(:float, 2)
    # locationsPtr[0] = 0.0
    # locationsPtr[1] = 1.0

    colorSpace = CGColorSpaceCreateDeviceRGB()
    colors = [color1.CGColor, color2.CGColor]
    gradient = CGGradientCreateWithColors(colorSpace, colors, nil)
    
    startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
    endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))
 
    path = UIBezierPath.bezierPathWithRoundedRect(rect, 
      byRoundingCorners: UIRectCornerAllCorners, # UIRectCornerTopRight | UIRectCornerBottomRight, 
      cornerRadii: CGSizeMake(2,2)
    )
     
    CGContextSaveGState(context)
    path.addClip
    CGContextClip(context)
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
end
