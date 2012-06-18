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
    labelWidth = 120
    
    value = mod[comparision.param].to_f
    # width = value * bounds.size.width / comparision.max_value
    width = value * (bounds.size.width - labelWidth - 5) / comparision.max_value
    rect = CGRectMake(0, 5, width, 18)
        
    # CGContextSetLineWidth(context, 20)
    # CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor)
    # CGContextMoveToPoint(context, 0, 15)
    # CGContextAddLineToPoint(context, width, 15)
    # CGContextStrokePath(context)

    # CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor)
    # CGContextFillRect(context, bar)
    
    title = mod.full_name
    parameter = mod[comparision.param].to_s
    
    actualFontSize = Pointer.new(:float)

    # title.drawAtPoint CGPointMake(5, 8), forWidth:bounds.size.width - 5, 
    #       withFont:UIFont.systemFontOfSize(11), minFontSize:8, actualFontSize:actualFontSize,
    #       lineBreakMode:UILineBreakModeTailTruncation, baselineAdjustment:UIBaselineAdjustmentAlignBaselines

    modelRect = CGRectMake(5, 0, labelWidth, 16)
    detailRect = CGRectMake(5, 11, labelWidth, 16)
    barRect = CGRectMake(labelWidth + 10, 4, width, 12)

    Helper.drawGradientRect context, barRect, UIColor.yellowColor, UIColor.orangeColor

    model_name_color = mod.premium? ? UIColor.blueColor : UIColor.blackColor
    Helper.drawStringInRect mod.branded_model_name, modelRect, model_name_color, 11, UILineBreakModeClip, UITextAlignmentRight
    Helper.drawStringInRect mod.mod_name, detailRect, UIColor.darkGrayColor, 8, UILineBreakModeClip, UITextAlignmentRight
    Helper.drawStringInRect parameter, barRect, UIColor.blackColor, 8, UILineBreakModeClip, UITextAlignmentRight

    # title.drawInRect CGRectMake(5, 8, width, 18),
    #   withFont:UIFont.systemFontOfSize(11), lineBreakMode:UILineBreakModeClip, alignment:UITextAlignmentLeft


    # UIColor.blackColor.set
    # title.drawInRect CGRectMake(5, 8, width, 18),
    #   withFont:UIFont.systemFontOfSize(11), lineBreakMode:UILineBreakModeClip, alignment:UITextAlignmentLeft
    # 
    # UIColor.grayColor.set    
    # parameter.drawInRect CGRectMake(bounds.size.width - 35, 8, 30, bounds.size.height - 8),
    #   withFont:UIFont.systemFontOfSize(11), lineBreakMode:UILineBreakModeClip, alignment:UITextAlignmentRight
    
    # parameter.drawAtPoint CGPointMake(bounds.size.width - 35, 8), forWidth:30,
    #   withFont:UIFont.systemFontOfSize(11), minFontSize:8, actualFontSize:actualFontSize,
    #   lineBreakMode:UILineBreakModeTailTruncation, baselineAdjustment:UIBaselineAdjustmentAlignBaselines
      
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
