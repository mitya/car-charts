module KK::Graphics
  def rectWithChangedWidth(rect, widthDelta)
    CGRectMake(rect.x, rect.y, rect.width + widthDelta, rect.height)
  end    

  def drawRect(rect, inContext:context, withGradientColors:colors, cornerRadius:cornerRadius)
    colorSpace = CGColorSpaceCreateDeviceRGB()
    colors = colors.map { |c| c.CGColor }
    gradient = CGGradientCreateWithColors(colorSpace, colors, nil)
  
    startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))
    endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))

    path = UIBezierPath.bezierPathWithRoundedRect(rect, 
      byRoundingCorners: UIRectCornerAllCorners,
      cornerRadii: CGSizeMake(cornerRadius, cornerRadius)
    )
   
    CGContextSaveGState(context)
    path.addClip
    CGContextClip(context) unless CGContextIsPathEmpty(context)
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)
    CGContextRestoreGState(context)
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

      KK.drawString string, inRect:rect, withColor:colorize(color), font:font, lineBreakMode:UILineBreakModeClip, alignment:UITextAlignmentLeft
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

KK.extend(KK::Graphics)
