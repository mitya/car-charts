$es_benchmarking = false
$es_profiling_time = nil
$es_profiling_results = []

class Helpers
  module Common
    def app
      UIApplication.sharedApplication
    end
  
    def defaults
      NSUserDefaults.standardUserDefaults
    end
  
    def indexPath(section, row)
      NSIndexPath.indexPathForRow(row, inSection: section)
    end
  
    def sequentialIndexPaths(section, firstRow, lastRow)
      return [] if firstRow > lastRow
      firstRow.upto(lastRow).map { |row| indexPath(section, row) }
    end
  
    def ptr(type = :object)
      Pointer.new(type)
    end
  
    def documentsURL
      NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).first
    end    
    
    def navigationForController(controller, withDelegate:delegate)
      KKNavigationController.alloc.initWithRootViewController(controller).tap do |navigation|
        navigation.delegate = delegate
        navigation.navigationBar.barStyle = UIBarStyleBlack
        navigation.toolbar.barStyle = UIBarStyleBlack
      end
    end
  end
  
  module Graphics
    def rectWithChangedWidth(rect, widthDelta)
      CGRectMake(rect.x, rect.y, rect.width + widthDelta, rect.height)
    end    

    def drawRect(rect, inContext:context, withGradientColors:colors, cornerRadius:cornerRadius)
      # locationsPtr = Pointer.new(:float, 2)
      # locationsPtr[0] = 0.0
      # locationsPtr[1] = 1.0

      colorSpace = CGColorSpaceCreateDeviceRGB()
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

    def drawString(string, inRect:rect, withColor:color, font:font, lineBreakMode:lineBreakMode, alignment:alignment)
      colorize(color).set if color
      font = fontize(font)
      string.drawInRect rect, withFont:font, lineBreakMode:lineBreakMode, alignment:alignment
    end 

    def drawString(string, inRect:rect, withColor:color, font:font, alignment:alignment)
      drawString(string, inRect:rect, withColor:color, font:font, lineBreakMode:UILineBreakModeClip, alignment:alignment)
    end 
    
    def drawInRect(frame, stringsSpecs:stringSpecs, alignment:alignment)
      lastStringEdge = nil
      stringSpecs.reverse! if alignment == UITextAlignmentRight
      stringSpecs.each_with_index do |(string, color, font, margin), index|
        font = fontize(font)
        size = string.sizeWithFont(font)

        case alignment when UITextAlignmentLeft
          rect = CGRectMake(lastStringEdge || frame.x, frame.y + (frame.height - size.height), size.width, size.height)
          lastStringEdge = rect.x + size.width + margin
        when UITextAlignmentRight
          rect = CGRectMake((lastStringEdge || frame.width) - size.width, frame.y + (frame.height - size.height), size.width, size.height)
          lastStringEdge = rect.x - margin
        when UITextAlignmentCenter # works only for 2 items, aligning both to edges
          rect = index == 0 ?
            CGRectMake(frame.x + margin, frame.y + (frame.height - size.height), size.width, size.height) :
            CGRectMake(frame.width - size.width, frame.y + (frame.height - size.height), size.width, size.height)
        end

        ES.drawString string, inRect:rect, withColor:colorize(color), font:font, lineBreakMode:UILineBreakModeClip, alignment:UITextAlignmentLeft
      end            
    end
    
    def drawInRect(frame, stringsSpecs:stringSpecs)
      drawInRect(frame, stringsSpecs:stringSpecs, alignment:UITextAlignmentLeft)
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
    
    def animateWithDuration(duration, options = {}, &animations)
      completion = options[:completion]

      if duration == 0
        animations.call
        completion.call if completion
      else
        if completion        
          UIView.animateWithDuration(duration, animations:animations, completion:completion)
        else
          UIView.animateWithDuration(duration, animations:animations)
        end

        # UIView.beginAnimations(nil, context:NULL)
        # UIView.setAnimationDuration(duration)
        # yield
        # UIView.commitAnimations
      end
    end
  end
  
  module Device
    def landscape?(orientation = UIApplication.sharedApplication.statusBarOrientation)
       orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight
    end

    def portrait?(orientation = UIApplication.sharedApplication.statusBarOrientation)
       orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown
    end
  
    def orientationKey(orientation = UIApplication.sharedApplication.statusBarOrientation) 
      portrait?(orientation) ? :portrait : :landscape
    end
    
    def currentScreenHeight
      portrait?? UIScreen.mainScreen.bounds.height : UIScreen.mainScreen.bounds.width
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
      return block.call unless $es_benchmarking

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
    
    def stackSpacer(view, width, height)
      spacer = UIView.alloc.initWithFrame(CGRectMake(0, 0, width, height))
      spacer.autoresizingMask = UIViewAutoresizingFlexibleWidth
      view.addSubview(spacer)
      spacer
    end
    
    def stackViews(views)
      y = views.first.frame.y
      views.each do |view|
        view.frame = CGRectMake(view.bounds.x, y, view.bounds.width, view.bounds.height)
        y += view.bounds.height
      end
    end

    def emptyView(options)
      title = options[:title]
      subtitle = options[:subtitle]
      frame = options[:frame]
      
      view = UIView.alloc.init
      view.frame = CGRectMake(frame.x + 15, 0, frame.width - 30, frame.height)
      view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight

      titleFont = UIFont.boldSystemFontOfSize(17)
      titleHeight = title.sizeWithFont(titleFont, constrainedToSize:view.bounds.size).height
      titleLabel = UILabel.alloc.initWithFrame(CGRectMake(0, ZERO, view.bounds.width, titleHeight))
      titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
      titleLabel.text = title
      titleLabel.textAlignment = UITextAlignmentCenter
      titleLabel.lineBreakMode = UILineBreakModeWordWrap
      titleLabel.textColor = UIColor.grayColor
      titleLabel.backgroundColor = UIColor.clearColor
      titleLabel.font = titleFont
      titleLabel.numberOfLines = 0

      if subtitle
        subtitleFont = UIFont.systemFontOfSize(12)
        subtitleHeight = subtitle.sizeWithFont(subtitleFont, constrainedToSize:view.bounds.size).height
        subtitleLabel = UILabel.alloc.initWithFrame(CGRectMake(0, ZERO, view.bounds.width, subtitleHeight))
        subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = UITextAlignmentCenter
        subtitleLabel.lineBreakMode = UILineBreakModeWordWrap
        subtitleLabel.textColor = UIColor.grayColor
        subtitleLabel.backgroundColor = UIColor.clearColor
        subtitleLabel.font = subtitleFont
        subtitleLabel.numberOfLines = 0
      end
      
      ES.stackViews [ES.stackSpacer(view, view.frame.width, 70), titleLabel, ES.stackSpacer(view, view.frame.width, 8), subtitleLabel].compact
      
      view.addSubview(titleLabel)
      view.addSubview(subtitleLabel) if subtitleLabel
      
      view
    end
    
    def emptyViewLabel(text, bounds)
      label = UILabel.alloc.initWithFrame(bounds)
      label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      label.text = text
      label.textAlignment = UITextAlignmentCenter
      label.textColor = UIColor.grayColor
      label.backgroundColor = UIColor.clearColor
      label.font = UIFont.boldSystemFontOfSize(17)
      label.numberOfLines = 0
      label
    end
  
    def tableViewFooterLabel(text = "")
      font = UIFont.systemFontOfSize(15)
      textHeight = text.sizeWithFont(font).height
      topMargin = 6

      view = UIView.alloc.initWithFrame [[0, 0], [ZERO, textHeight + topMargin]]
      view.autoresizingMask = UIViewAutoresizingFlexibleWidth
      label = UILabel.alloc.initWithFrame([[0, topMargin], [view.frame.width, textHeight]]).tap do |label|
        label.text = text
        label.backgroundColor = UIColor.clearColor
        label.font = font
        label.textColor = ES.tableViewFooterColor
        label.shadowColor = UIColor.colorWithWhite(1, alpha:1)
        label.shadowOffset = CGSizeMake(0, 1)
        label.textAlignment = UITextAlignmentCenter
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth
        view.addSubview(label)        
      end
      
      view
    end

    def tableViewGrayBackground
      screen = UIScreen.mainScreen.applicationFrame
      topview = UIView.alloc.initWithFrame(CGRectMake(0, -screen.height, screen.width, screen.height))
      topview.backgroundColor = ES.rgb(226, 231, 238)
      topview.autoresizingMask = UIViewAutoresizingFlexibleWidth
      topview
    end  
  
    def customBBI(view = nil)
      view ||= yield
      UIBarButtonItem.alloc.initWithCustomView(view)
    end
    
    def systemBBI(style)
      systemBBI(style, target:NIL, action:NIL)
    end
  
    def systemBBI(style, target:target, action:action)
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(style, target:target, action:action)
    end

    def imageBBI(imageName, target:target, action:action)
      UIBarButtonItem.alloc.initWithImage(UIImage.imageNamed(imageName), style:UIBarButtonItemStyleBordered, target:target, action:action)      
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
  
    def fixedSpaceBBI(width = nil)
      ES.fixedSpaceBBIWithWidth(nil)
    end

    def fixedSpaceBBIWithWidth(width = nil)
      ES.systemBBI(UIBarButtonSystemItemFixedSpace, target:nil, action:nil).tap { |bbi| bbi.width = width if width }
    end
  
    def plainBBI(imageName, target:target, action:action, options:options)
      options = NSDictionary.dictionary if options == nil

      button = UIButton.buttonWithType(UIButtonTypeCustom)
      button.frame = [[0, 0], options[:size] || [20, 20]]
      button.setImage UIImage.imageNamed(imageName), forState:UIControlStateNormal
      button.setImage UIImage.imageNamed(options[:selected]), forState:UIControlStateSelected if options[:selected]
      button.showsTouchWhenHighlighted = YES
      button.addTarget target, action:action, forControlEvents:UIControlEventTouchUpInside

      customBBI(button)      
    end

    def segmentedControl(items)
      segmentedControl = UISegmentedControl.alloc.initWithItems(items)
      segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
      segmentedControl
    end    
  end

  module Profiling
    def profileBegin(title = nil)
      $es_profiling_title = title
      $es_profiling_results = []
      $es_profiling_time = Time.now
    end

    def profilePrint(label)
      elapsed = (Time.now - $es_profiling_time) * 1_000
      NSLog("TIMING #{label}: #{"%.3f" % elapsed}ms")
      $es_profiling_time = Time.now
    end

    def profile(label)
      elapsed = (Time.now - $es_profiling_time) * 1_000
      $es_profiling_results << [label, elapsed]
      $es_profiling_time = Time.now
    end

    def profileEnd
      text = $es_profiling_results.map { |data| "%s %.3f" % data }.join(', ')
      NSLog("TIMING #{$es_profiling_title} #{text}")
    end    
  end
  
  include Common, Graphics, Device, Operations, Development, Colors, Fonts, UI, Profiling
end

KK = Helpers.new
ES = KK
