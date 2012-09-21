class BarTableViewCell < UITableViewCell
  attr_accessor :barView
  attr_delegated 'barView', :item
  
  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    if super(UITableViewCellStyleDefault, reuseIdentifier:reuseIdentifier)
      barFrame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height)
      self.barView = BarView.alloc.initWithFrame(barFrame)
      self.barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.contentView.addSubview(barView)
    end
    self
  end
end


class BarViewInfo
  attr_accessor :param, :value, :width, :rect, :index, :mod
    
  def value
    mod[param]
  end
    
  def param_text
    Float === value ? "%.1f" % value : value
  end
    
  def text
    "#{param_text} #{param.unitName}"
  end
end


class BarView < UIView  
  attr_accessor :item
  attr_delegated 'item', :mod, :mods, :index, :comparision

  BarHeight = 10
  BarFullHeight = 11
  BarTitleHeight = 13 # 14
  BarDetailHeight = 11
  BarLabelsLeftMargin = 5
  BarLabelsWidth = 120
  BarRightMargin = 7
  BarPremiumBrandColor = Hel.rgb(202, 0, 50)

  def initWithFrame(frame)
    if super(frame)
      self.opaque = true
      self.backgroundColor = Hel.pattern("bg-chart")
    end
    self
  end

  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    
    minWidth = 40
    pixelRange = bounds.width - BarLabelsWidth - BarLabelsLeftMargin - minWidth - BarRightMargin
    
    bars = comparision.params.map do |param|
      firstBarShift = item.first?? BarTitleHeight : 0

      bar = BarViewInfo.new
      bar.index = comparision.params.index(param)
      bar.param = param
      bar.mod = mod
      bar.width = (bar.value - comparision.min_value_for(param)) * pixelRange / comparision.range_for(param) + minWidth
      bar.rect = CGRectMake(BarLabelsWidth + 10, 1 + firstBarShift + bar.index * BarFullHeight, bar.width, BarHeight)
      bar
    end
    
    modelRect = CGRectMake(BarLabelsLeftMargin, 0, BarLabelsWidth, BarHeight)
    detailRect = CGRectMake(BarLabelsLeftMargin, item.first?? BarTitleHeight : 0, BarLabelsWidth, BarDetailHeight)

    if item.first?
      modelNameColor = UIColor.blackColor # mod.model.brand.premium? ? BarPremiumBrandColor : UIColor.blackColor
      Hel.drawStringInRect mod.model.name, modelRect, modelNameColor, 11, UILineBreakModeClip, UITextAlignmentRight
    end

    modTitle = comparision.onlyBodyParams?? mod.version : mod.mod_name
    Hel.drawStringInRect modTitle, detailRect, UIColor.darkGrayColor, 8, UILineBreakModeClip, UITextAlignmentRight

    bars.each do |bar|
      rect = bar.rect
      oversized = rect.width >= (bounds.width - BarLabelsWidth - 5)
      textWidth = oversized ? (bounds.width - BarLabelsWidth - 12) : rect.width - 4
      textColor = UIColor.whiteColor
      textFont = oversized ? UIFont.boldSystemFontOfSize(9) : UIFont.systemFontOfSize(8)
      bgColors = self.class.colors[bar.index]
      
      Hel.drawGradientRect context, rect, bgColors
      Hel.drawStringInRect bar.text, CGRectMake(rect.x, rect.y - 1, textWidth, rect.height), textColor, textFont, UILineBreakModeClip, UITextAlignmentRight
    end
  end
  
  def self.colors
    @colors ||= [
      [Hel.rgb(0, 90, 180), Hel.rgb(108, 164, 220)].reverse,
      [Hel.rgb(2, 120, 2), Hel.rgb(63, 153, 63)].reverse,
      [Hel.rgb(120, 2, 2), Hel.rgb(153, 63, 63)].reverse,
      [Hel.rgb(2, 2, 120), Hel.rgb(63, 63, 153)].reverse,
      [Hel.rgb(120, 120, 2), Hel.rgb(153, 153, 63)].reverse,
    ]
  end
end
