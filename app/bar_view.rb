class BarView < UIView
  class BarSpec
    attr_accessor :param, :value, :width, :rect, :index, :mod
    
    def text
      "#{mod[param]} #{Model.unit_name_for(param)}"
    end
  end

  attr_accessor :mods, :modIndex, :comparision
    
  def initWithFrame(frame)
  	if super(frame)
  		self.opaque = true
  		self.backgroundColor = UIColor.whiteColor
    end
  	self
  end

  def mod
    @mod ||= mods[modIndex]
  end

  def first_bar_for_same_model?
    false
  end
  
  def next_bar_for_same_model?
    false
  end

  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    labelWidth = 120
    minWidth = 40
    pixelRange = bounds.width - labelWidth - 5 - minWidth - 5
    
    barSpecs = comparision.params.map do |param|
      barSpec = BarSpec.new
      barSpec.index = comparision.params.index(param)
      barSpec.mod = mod
      barSpec.param = param
      barSpec.value = mod[param].to_f
      # barSpec.width = barSpec.value * (bounds.width - labelWidth - 5) / comparision.max_value_for(param)
      barSpec.width = (barSpec.value - comparision.min_value_for(param)) * pixelRange / comparision.range_for(param) + minWidth
      # barSpec.width = barSpec.value * (bounds.width - labelWidth - 5) / range
      barSpec.rect = CGRectMake(labelWidth + 10, 2 + barSpec.index * 14, barSpec.width, 12)
      barSpec
    end
    
    # CGContextSetLineWidth(context, 20)
    # CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor)
    # CGContextMoveToPoint(context, 0, 15)
    # CGContextAddLineToPoint(context, width, 15)
    # CGContextStrokePath(context)

    # CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor)
    # CGContextFillRect(context, bar)
    
    title = mod.full_name
    actualFontSize = Pointer.new(:float)

    # title.drawAtPoint CGPointMake(5, 8), forWidth:bounds.size.width - 5, 
    #       withFont:UIFont.systemFontOfSize(11), minFontSize:8, actualFontSize:actualFontSize,
    #       lineBreakMode:UILineBreakModeTailTruncation, baselineAdjustment:UIBaselineAdjustmentAlignBaselines

    modelRect = CGRectMake(5, 0, labelWidth, 16)
    detailRect = CGRectMake(5, 11, labelWidth, 16)

    colors = [
      [Helper.rgbColor(0, 90, 180), Helper.rgbColor(108, 164, 220)].reverse,
      [Helper.rgbColor(2, 120, 2), Helper.rgbColor(63, 153, 63)].reverse,
      [Helper.rgbColor(120, 2, 2), Helper.rgbColor(153, 63, 63)].reverse,
    ]

    model_name_color = mod.premium? ? UIColor.blueColor : UIColor.blackColor
    Helper.drawStringInRect mod.branded_model_name, modelRect, model_name_color, 11, UILineBreakModeClip, UITextAlignmentRight
    Helper.drawStringInRect mod.mod_name, detailRect, UIColor.darkGrayColor, 8, UILineBreakModeClip, UITextAlignmentRight

    barSpecs.each do |barSpec|
      rect = barSpec.rect
      oversized = rect.width >= (bounds.width - labelWidth - 5)
      textWidth = oversized ? (bounds.width - labelWidth - 12) : rect.width - 4

      # printf "%60s %12s %3ipx %3ipx %s\n", barSpec.mod.key, barSpec.text, rect.width, textWidth, '*' * (rect.width / 10)

      # textColor = oversized ? Helper.rgbColor(255, 255, 102) : UIColor.whiteColor
      textColor = UIColor.whiteColor
      textFont = oversized ? UIFont.boldSystemFontOfSize(9) : UIFont.systemFontOfSize(8)
      bgColors = colors[barSpec.index]
      
      Helper.drawGradientRect context, rect, bgColors
      Helper.drawStringInRect barSpec.text, CGRectMake(rect.x, rect.y, textWidth, rect.height), textColor, textFont, UILineBreakModeClip, UITextAlignmentRight
    end

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
  attr_accessor :barView
  attr_delegated 'barView', :mods, :modIndex, :comparision
  
  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
  	if super(UITableViewCellStyleDefault, reuseIdentifier:reuseIdentifier)
      barFrame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height)
      self.barView = BarView.alloc.initWithFrame(barFrame)
      barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      contentView.addSubview(barView)
    end
  	self
  end
end
