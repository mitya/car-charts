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
  BarPremiumBrandColor = ES.rgb(202, 0, 50)

  def initWithFrame(frame)
    if super(frame)
      self.opaque = true
      self.backgroundColor = ES.pattern("bg-chart")
    end
    self
  end

  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    
    labelWidth = bounds.width * 0.4    
  
    minWidth = 40
    pixelRange = bounds.width - labelWidth - BarLabelsLeftMargin - minWidth - BarRightMargin
    
    bars = comparision.params.map do |param|
      firstBarShift = item.first?? BarTitleHeight : 0

      bar = BarViewInfo.new
      bar.index = comparision.params.index(param)
      bar.param = param
      bar.mod = mod
      bar.width = (bar.value - comparision.minValueFor(param)) * pixelRange / comparision.rangeFor(param) + minWidth
      bar.rect = CGRectMake(labelWidth + 10, 1 + firstBarShift + bar.index * BarFullHeight, bar.width, BarHeight)
      bar
    end
    
    modelRect = CGRectMake(BarLabelsLeftMargin, 0, labelWidth, BarHeight)
    detailRect = CGRectMake(BarLabelsLeftMargin, item.first?? BarTitleHeight : 0, labelWidth, BarDetailHeight)

    if item.first?
      modelNameColor = UIColor.blackColor # mod.model.brand.premium? ? BarPremiumBrandColor : UIColor.blackColor
      ES.drawStringInRect mod.model.name, modelRect, modelNameColor, 11, UILineBreakModeClip, UITextAlignmentRight
    end

    modTitle = comparision.containsOnlyBodyParams?? mod.version : mod.modName
    ES.drawStringInRect modTitle, detailRect, UIColor.darkGrayColor, 8, UILineBreakModeClip, UITextAlignmentRight

    bars.each do |bar|
      rect = bar.rect
      oversized = rect.width >= (bounds.width - labelWidth - 5)
      textWidth = oversized ? (bounds.width - labelWidth - 12) : rect.width - 4
      textColor = UIColor.whiteColor
      textFont = oversized ? UIFont.boldSystemFontOfSize(9) : UIFont.systemFontOfSize(8)
      bgColors = self.class.colors[bar.index.remainder(self.class.colors.count)]
      
      ES.drawGradientRect context, rect, bgColors
      ES.drawStringInRect bar.text, CGRectMake(rect.x, rect.y - 1, textWidth, rect.height), textColor, textFont, UILineBreakModeClip, UITextAlignmentRight
    end
  end
  
  def self.colors
    @colors ||= Metadata.colors.map do |values|
      h,s,b = values
      [ES.hsb(h, s - 10, b + 5), ES.hsb(h, s + 10, b - 5)]
    end
  end
end
