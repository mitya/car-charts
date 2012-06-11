class BarView < UIView
  attr_accessor :mod, :comparision
    
  def initWithFrame(frame)
  	if super(frame)
  		self.opaque = true
  		self.backgroundColor = UIColor.whiteColor
    end
  	self
  end

  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    
    value = mod[comparision.param].to_f
    width = value * bounds.size.width / comparision.max_value
    rect = CGRectMake(0, 5, width, 20)
        
    # CGContextSetLineWidth(context, 20)
    # CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor)
    # CGContextMoveToPoint(context, 0, 15)
    # CGContextAddLineToPoint(context, width, 15)
    # CGContextStrokePath(context)

    # CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor)
    # CGContextFillRect(context, bar)
    
    Helper.drawGradientRect(context, rect, UIColor.yellowColor, UIColor.redColor)
    
    title = mod.full_name
    parameter = mod[comparision.param].to_s
    
    UIColor.blackColor.set
    actualFontSize = Pointer.new(:float)

		title.drawAtPoint CGPointMake(5, 8), forWidth:bounds.size.width - 5, 
      withFont:UIFont.systemFontOfSize(11), minFontSize:10, actualFontSize:actualFontSize,
      lineBreakMode:UILineBreakModeTailTruncation, baselineAdjustment:UIBaselineAdjustmentAlignBaselines
      
    UIColor.grayColor.set
		parameter.drawAtPoint CGPointMake(width + 5, 8), forWidth:30, 
      withFont:UIFont.systemFontOfSize(11), minFontSize:10, actualFontSize:actualFontSize,
      lineBreakMode:UILineBreakModeTailTruncation, baselineAdjustment:UIBaselineAdjustmentAlignBaselines
      
  end
end

class BarTableViewCell < UITableViewCell
  attr_accessor :mod, :comparision, :barView
  
  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
  	if super(UITableViewCellStyleDefault, reuseIdentifier:reuseIdentifier)
      barFrame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height)
      self.barView = BarView.alloc.initWithFrame(barFrame)
      barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      contentView.addSubview(barView)
    end
  	self
  end
  
  def mod=(mod)
    barView.mod = mod
  end

  def comparision=(comparision)
    barView.comparision = comparision
  end
end
