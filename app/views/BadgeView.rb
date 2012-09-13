# https://github.com/digdog/DDBadgeViewCell
class BadgeViewCell < UITableViewCell
  attr_accessor :summary, :detail, :badgeView, :badgeText, :badgeColor, :badgeHighlightedColor

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    if super(style, reuseIdentifier:reuseIdentifier)
      self.badgeView = BadgeView.alloc.init(contentView.bounds, self)
      badgeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      badgeView.contentMode = UIViewContentModeRedraw
      badgeView.contentStretch = CGRectMake(1, 0, 0, 0)
      contentView.addSubview(badgeView)
    end
    self
  end
  
  def dealloc
    self.summary = self.detail = self.badgeView = self.badgeText = self.badgeColor = self.badgeHighlightedColor = nil
    super
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

class BadgeView < UIView
  attr_accessor :cell
  
  def init(frame, cell)
    initWithFrame(frame)
    self.cell = cell
    self.backgroundColor = Color.clear
    self.layer.masksToBounds = true
    self
  end
  
  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()

    currentSummaryColor = Color.black
    currentDetailColor = Color.gray
    currentBadgeColor = cell.badgeColor || Hel.rgbf(0.53, 0.6, 0.738)
    
  	if cell.isHighlighted || cell.isSelected
      currentSummaryColor = Color.white
      currentDetailColor = Color.white
  		currentBadgeColor = cell.badgeHighlightedColor || Color.white
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
