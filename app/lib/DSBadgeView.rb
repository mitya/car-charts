# https://github.com/digdog/DDDSBadgeViewCell
class DSBadgeViewCell < UITableViewCell
  attr_accessor :summary, :detail, :badgeView, :badgeText, :badgeColor, :badgeHighlightedColor

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    if super
      self.badgeView = DSBadgeView.alloc.init(contentView.bounds, self)
      badgeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      badgeView.contentMode = UIViewContentModeRedraw
      contentView.addSubview(badgeView)
    end
    self
  end
  
  def layoutSubviews
    super
    if detailTextLabel
      base = detailTextLabel.frame
      detailTextLabel.frame = CGRectMake(base.x, base.y, bounds.width - 50, base.height)
    end
  end
  
  def badgeText=(value)
    @badgeText = value && value != 0 ? value.to_s : nil
  end
  
  def setSelected(selected, animated:animated)
    super
  	badgeView.setNeedsDisplay
  end

  def setHighlighted(highlighted, animated:animated)
  	super
  	badgeView.setNeedsDisplay
  end

  def setEditing(editing, animated:animated)
  	super
  	badgeView.setNeedsDisplay
  end
end

class DSBadgeView < UIView
  attr_accessor :cell
  
  def init(frame, cell)
    initWithFrame(frame)
    self.cell = cell
    self.backgroundColor = UIColor.clearColor
    self.layer.masksToBounds = true
    self
  end
  
  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()

    currentSummaryColor = UIColor.blackColor
    currentDetailColor = UIColor.grayColor
    currentBadgeColor = cell.badgeColor || ES.rgbf(0.53, 0.6, 0.738)
    
  	if cell.isHighlighted || cell.isSelected
      currentSummaryColor = UIColor.whiteColor
      currentDetailColor = UIColor.whiteColor
  		currentBadgeColor = cell.badgeHighlightedColor || UIColor.whiteColor
    end

  	if cell.isEditing
      if cell.summary
        currentSummaryColor.set
        cell.summary.drawAtPoint CGPointMake(10, 10), forWidth:rect.width, withFont:UIFont.boldSystemFontOfSize(18), lineBreakMode:UILineBreakModeTailTruncation
      end

      if cell.detail
        currentDetailColor.set
        cell.detail.drawAtPoint CGPointMake(10, 32), forWidth:rect.width, withFont:UIFont.systemFontOfSize(14), lineBreakMode:UILineBreakModeTailTruncation 
      end
  	else
  		badgeTextSize = cell.badgeText.to_s.sizeWithFont(UIFont.boldSystemFontOfSize(13))
  		badgeViewFrame = CGRectIntegral(CGRectMake(
        rect.width - badgeTextSize.width - 24, (rect.height - badgeTextSize.height - 4) / 2, 
        badgeTextSize.width + 14, badgeTextSize.height + 4))

      if cell.badgeText
    		CGContextSaveGState(context)
    		CGContextSetFillColorWithColor(context, currentBadgeColor.CGColor)
    		path = CGPathCreateMutable()
    		CGPathAddArc(path, nil, 
          badgeViewFrame.x + badgeViewFrame.width - badgeViewFrame.height / 2, badgeViewFrame.y + badgeViewFrame.height / 2, 
          badgeViewFrame.height / 2, M_PI / 2, M_PI * 3 / 2, true)
    		CGPathAddArc(path, nil, 
          badgeViewFrame.x + badgeViewFrame.height / 2, badgeViewFrame.y + badgeViewFrame.height / 2, 
          badgeViewFrame.height / 2, M_PI * 3 / 2, M_PI / 2, true)
    		CGContextAddPath(context, path)
    		CGContextDrawPath(context, KCGPathFill)
    		CGContextRestoreGState(context)

    		CGContextSaveGState(context)
    		CGContextSetBlendMode(context, KCGBlendModeClear)
    		cell.badgeText.drawInRect CGRectInset(badgeViewFrame, 7, 2), withFont:UIFont.boldSystemFontOfSize(13)
    		CGContextRestoreGState(context)
      end

      if cell.summary
        currentSummaryColor.set
        cell.summary.drawAtPoint CGPointMake(10, 10), forWidth:(rect.width - badgeViewFrame.width - 24), 
          withFont:UIFont.boldSystemFontOfSize(18), lineBreakMode:UILineBreakModeTailTruncation
      end

      if cell.detail
        currentDetailColor.set
        cell.detail.drawAtPoint CGPointMake(10, 32), forWidth:(rect.width - badgeViewFrame.width - 24), 
          withFont:UIFont.systemFontOfSize(14), lineBreakMode:UILineBreakModeTailTruncation
      end
    end
  end
end
