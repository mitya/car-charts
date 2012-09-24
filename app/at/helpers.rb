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
  
  def hsb(h, s, v, a = 1.0)
    UIColor.colorWithHue(h / 360.0, saturation: s / 100.0,  brightness: v / 100.0, alpha: a)
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
  
  def pattern(imageName)
    UIColor.colorWithPatternImage(UIImage.imageNamed(imageName))
  end
  
  # Other
  
  def benchmark(actionName = "Action", &block)
    startTime = Time.now
    result = block.call
    elapsed = (Time.now - startTime) * 1_000
    NSLog "TIMING #{actionName}: #{"%.3f" % elapsed}ms"
    result
  end
  
  def landscape?(orientation)
     orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight
  end

  def portrait?(orientation)
     orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown
  end
  
  def portraitNow?
    portrait?(UIApplication.sharedApplication.statusBarOrientation)
  end
  
  def orientationKey
    orientation = UIApplication.sharedApplication.statusBarOrientation
    portrait?(orientation) ? :portrait : :landscape
  end
  
  def loadJSON(file, type)
    path = NSBundle.mainBundle.pathForResource(file, ofType:type)
    error = Pointer.new(:object)
    NSJSONSerialization.JSONObjectWithData(NSData.dataWithContentsOfFile(path), options:0, error:error)
  end
  
  def grayTableViewTop
    topview = UIView.alloc.initWithFrame(CGRectMake(0,-480,320,480))
    topview.backgroundColor = Hel.rgb(226, 231, 238)    
    topview.autoresizingMask = UIViewAutoresizingFlexibleWidth
    topview
  end
  
  def setDevBorder(view)
    view.layer.borderColor = UIColor.redColor.CGColor
    view.layer.borderWidth = 1
    view.layer.cornerRadius = 8
    view.layer.masksToBounds = true    
  end
  
  def tableViewPlaceholder(text, bounds)
    placeholder = UILabel.alloc.initWithFrame(bounds)
    placeholder.autoresizingMask = UIViewAutoresizingFlexibleAllMargins
    placeholder.text = text
    placeholder.textAlignment = UITextAlignmentCenter
    placeholder.textColor = Hel.grayShade(0.7)
    placeholder.backgroundColor = UIColor.clearColor
    placeholder.font = UIFont.systemFontOfSize(20)
    placeholder.numberOfLines = 0
    placeholder
  end
  
  def customBBI(view)
    UIBarButtonItem.alloc.initWithCustomView(view)
  end
  
  def systemBBI(style, target:target, action:action)
    UIBarButtonItem.alloc.initWithBarButtonSystemItem(style, target:target, action:action)
  end

  def textBBI(text)
    UIBarButtonItem.alloc.initWithTitle(text, style:UIBarButtonItemStyleBordered, target:nil, action:nil)
  end
  
  def textBBI(text, target:target, action:action)
    UIBarButtonItem.alloc.initWithTitle(text, style:UIBarButtonItemStyleBordered, target:target, action:action)
  end
  
  def segmentedControl(items)
    segmentedControl = UISegmentedControl.alloc.initWithItems(items)
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
    segmentedControl
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
