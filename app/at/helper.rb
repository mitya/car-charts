class Helper
  module Common
    def app
      UIApplication.sharedApplication.delegate
    end
  
    def defaults
      NSUserDefaults.standardUserDefaults
    end
  
    def indexPath(row, section = 0)
      NSIndexPath.indexPathForRow(row, inSection: section)
    end
  
    def ptr(type = :object)
      Pointer.new(type)
    end
  
    def documentsURL
      NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).first
    end    
  end
  
  module Graphics
    def rectWithChangedWidth(rect, widthDelta)
      CGRectMake(rect.x, rect.y, rect.width + widthDelta, rect.height)
    end    

    def drawRect(rect, inContext:context, withGradientColors:colors, cornerRadius:cornerRadius)
      drawGradientRect(context, rect, colors, cornerRadius)
    end

    def drawGradientRect(context, rect, colors, cornerRadius = 2)
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
        cornerRadii: CGSizeMake(cornerRadius, cornerRadius)
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
      colorize(color).set if color
      font = fontize(font)
      string.drawInRect rect, withFont:font, lineBreakMode:lineBreakMode, alignment:alignment
    end   
    
    def drawString(string, inRect:rect, withColor:color, font:font, lineBreakMode:lineBreakMode, alignment:alignment)
      drawStringInRect(string, rect, color, font, lineBreakMode, alignment)
    end 

    def drawString(string, inRect:rect, withColor:color, font:font, alignment:alignment)
      drawString(string, inRect:rect, withColor:color, font:font, lineBreakMode:UILineBreakModeClip, alignment:alignment)
    end 
    
    def drawInRect(frame, stringsSpecs:stringSpecs)
      lastStringRightEdge = nil
      stringSpecs.each_with_index do |(string, color, font, rightMargin), index|
        font = fontize(font)
        size = string.sizeWithFont(font)
        rect = CGRectMake(lastStringRightEdge || frame.x, frame.y + (frame.height - size.height), size.width, size.height)
        lastStringRightEdge = rect.x + size.width + rightMargin
        ES.drawString string, inRect:rect, withColor:colorize(color), font:font, lineBreakMode:UILineBreakModeClip, alignment:UITextAlignmentLeft
      end      
    end
    
    def alignInlineViews(views, inContainer:container, withOptions:options)
      rows = [[]]
      x, y = options[:containerHM], options[:containerVM]

      # combine views into rows
      views.each_with_index do |view, index|
        view.sizeToFit
        if x + view.bounds.width + options[:viewRM] > container.bounds.width - options[:containerHM] # doesn't fit in a row
          x, y = options[:containerHM], y + options[:viewFH] 
          rows << []
        end
        view.frame = CGRectMake(x, y, view.bounds.width, view.bounds.height)
        rows.last << view
        x += view.bounds.width + options[:viewRM]
      end
      
      # distribute views inside rows
      rows.each do |row|
        rowWidth = row.reduce(0) { |width, view| width + view.bounds.width } + options[:viewRM] * (row.count - 1)
        spacing = (container.bounds.width - options[:containerHM] * 2 - rowWidth) / row.count
        row.each_with_index { |view, index| view.frame = CGRectOffset(view.frame, index * spacing + spacing * 0.5, 0) }
      end
      
      return y + options[:viewFH] + options[:containerVM] # views bottom edge
    end
    
    def alignBlockViews(views, inContainer:container, withOptions:options)
      y = options[:containerTM]

      views.each do |view|
        view.sizeToFit
        view.frame = CGRectMake(view.bounds.x + options[:containerHM], y, view.bounds.width, view.bounds.height)
        y += options[:viewFH]
      end
      
      return y
    end
    
    def setRoundedCornersForView(view, withRadius:radius, width:width, color:color)
      view.layer.borderColor = color.CGColor
      view.layer.borderWidth = width
      view.layer.cornerRadius = radius
      view.layer.masksToBounds = true     
    end
    
    def strokeRect(rect, inContext:context, withColor:color)
      colorize(color).setStroke if color
      CGContextStrokeRect(context, rect)
    end
    
    def animateWithDuration(duration)
      UIView.beginAnimations(nil, context:NULL)
      UIView.setAnimationDuration(duration)
      yield
      UIView.commitAnimations      
    end
  end
  
  module Device
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
  end
  
  module Operations
    def loadJSON(file, type)
      path = NSBundle.mainBundle.pathForResource(file, ofType:type)
      error = Pointer.new(:object)
      NSJSONSerialization.JSONObjectWithData(NSData.dataWithContentsOfFile(path), options:0, error:error)
    end    
  end
  
  module Development
    def benchmark(actionName = "Action", &block)
      return block.call unless $benchmarking

      startTime = Time.now
      result = block.call
      elapsed = (Time.now - startTime) * 1_000
      NSLog "TIMING #{actionName}: #{"%.3f" % elapsed}ms"
      result
    end
    
    def applyRoundCorners(view, cornerRadius = 8)
      view.layer.cornerRadius = cornerRadius
      view.layer.masksToBounds = true
    end  
  
    def setDevBorder(view, color = UIColor.redColor)
      view.layer.borderColor = colorize(color).CGColor
      view.layer.borderWidth = 1
      # view.layer.cornerRadius = 8
      # view.layer.masksToBounds = true    
    end    
  end

  module Colors
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
      UIColor.colorWithWhite(level, alpha:1.0)
    end

    def hex(value)
      r = value >> 16 & 0xFF
      g = value >> 8 & 0xFF
      b = value & 0xFF
      rgb(r, g, b)
    end 
  
    def colorize(color)
      return color if color.is_a?(UIColor)
      return UIColor.send("#{color}Color") if color.is_a?(String) || color.is_a?(Symbol)
      return color
    end

    def patternColor(imageName)
      UIColor.colorWithPatternImage(UIImage.imageNamed(imageName))
    end
    
    def blueTextColor
      rgb(81, 102, 145)
    end
    
    def grayTextColor
      grayShade(0.5)
    end
    
    def separatorColor
      grayShade(0.8)
    end
    
    def tableViewFooterColor
      ES.rgbf(0.298, 0.337, 0.424)
    end
    
    def checkedTableViewItemColor
      ES.rgbf(0.22, 0.33, 0.53)
    end
  end
  
  module Fonts
    def fontize(font)
      return font if font.is_a?(UIFont)
      return UIFont.systemFontOfSize(font) if font.is_a?(Numeric)
      return font
    end
    
    def mainFont(size)
      UIFont.systemFontOfSize(size)
    end    
    
    def boldFont(size)
      UIFont.boldSystemFontOfSize(size)
    end
  end
  
  module UI
    def capImage(imageName, top, left, bottom, right)
      UIImage.imageNamed(imageName).resizableImageWithCapInsets(UIEdgeInsetsMake(top, left, bottom, right))
    end
    
    def tableViewPlaceholder(text, bounds)
      placeholder = UILabel.alloc.initWithFrame(bounds)
      placeholder.autoresizingMask = UIViewAutoresizingFlexibleAllMargins
      placeholder.text = text
      placeholder.textAlignment = UITextAlignmentCenter
      placeholder.textColor = ES.grayShade(0.7)
      placeholder.backgroundColor = UIColor.clearColor
      placeholder.font = UIFont.systemFontOfSize(20)
      placeholder.numberOfLines = 0
      placeholder
    end
  
    def tableViewFooterLabel(text = "")
      font = UIFont.systemFontOfSize(15)
      textHeight = text.sizeWithFont(font).height
      topMargin = 6

      view = UIView.alloc.initWithFrame [[0, 0], [UIScreen.mainScreen.bounds.width, textHeight + topMargin]]
      label = UILabel.alloc.initWithFrame([[0, topMargin], [view.frame.width, textHeight]]).tap do |label|
        label.text = text
        label.backgroundColor = UIColor.clearColor
        label.font = font
        label.textColor = ES.tableViewFooterColor
        label.shadowColor = UIColor.colorWithWhite(1, alpha:1)
        label.shadowOffset = CGSizeMake(0, 1)
        label.textAlignment = UITextAlignmentCenter
        view.addSubview(label)        
      end
      
      view
    end

    def grayTableViewTop
      screen = UIScreen.mainScreen.applicationFrame
      topview = UIView.alloc.initWithFrame(CGRectMake(0, -screen.height, screen.width, screen.height))
      topview.backgroundColor = ES.rgb(226, 231, 238)
      topview.autoresizingMask = UIViewAutoresizingFlexibleWidth
      topview
    end  
  
    def customBBI(view)
      UIBarButtonItem.alloc.initWithCustomView(view)
    end

    def systemBBI(style)
      systemBBI(style, target:NIL, action:NIL)
    end
  
    def systemBBI(style, target:target, action:action)
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(style, target:target, action:action)
    end

    def imageBBI(imageName, style:style, target:target, action:action)
      UIBarButtonItem.alloc.initWithImage(UIImage.imageNamed(imageName), style:style, target:target, action:action)      
    end

    def textBBI(text)
      textBBI(text, style:UIBarButtonItemStyleBordered, target:NIL, action:NIL)
    end
  
    def textBBI(text, target:target, action:action)
      textBBI(text, style:UIBarButtonItemStyleBordered, target:target, action:action)
    end

    def textBBI(text, style:style, target:target, action:action)
      UIBarButtonItem.alloc.initWithTitle(text, style:style, target:target, action:action)
    end
    
    def flexibleSpaceBBI
      ES.systemBBI(UIBarButtonSystemItemFlexibleSpace)
    end
  
    def segmentedControl(items)
      segmentedControl = UISegmentedControl.alloc.initWithItems(items)
      segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
      segmentedControl
    end    
  end
  
  include Common, Graphics, Device, Operations, Development, Colors, Fonts, UI
end

ES = Helper.new

def ESStrokeRect(rect, context, color)
  ES.strokeRect(rect, inContext:context, withColor:color)
end

def ESFont(size, style = :normal)
  case style
    when :normal then UIFont.systemFontOfSize(size)
    when :bold then UIFont.boldSystemFontOfSize(size)
  end
end

ESFontLineHeights = { 
  6.0 => 8.0, 6.5 => 9.0, 7.0 => 10.0, 7.5 => 10.0, 8.0 => 11.0, 8.5 => 11.0, 9.0 => 12.0, 9.5 => 13.0, 10.0 => 13.0, 10.5 => 14.0,
  11.0 => 14.0, 11.5 => 14.0, 12.0 => 15.0, 12.5 => 15.0, 13.0 => 16.0, 13.5 => 18.0, 14.0 => 18.0, 14.5 => 19.0, 15.0 => 19.0,
  15.5 => 19.0, 16.0 => 20.0, 16.5 => 20.0, 17.0 => 21.0, 17.5 => 22.0, 18.0 => 22.0, 18.5 => 23.0, 19.0 => 23.0, 19.5 => 24.0,
  20.0 => 24.0, 20.5 => 25.0, 21.0 => 26.0, 21.5 => 26.0, 22.0 => 27.0, 22.5 => 28.0, 23.0 => 28.0, 23.5 => 29.0, 24.0 => 29.0, 24.5 => 29.0, 
}

def ESLineHeightFromFontSize(size)
  ESFontLineHeights[size.to_f]
end

# $benchmarking = true
