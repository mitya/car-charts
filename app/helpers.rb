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
 
    CGContextSaveGState(context)
    CGContextAddRect(context, rect)
    CGContextClip(context)
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)
    CGContextRestoreGState(context)
 
    # CGGradientRelease(gradient)
    # CGColorSpaceRelease(colorSpace)    
  end  
end