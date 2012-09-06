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
    "#{param_text} #{Model.unit_name_for(param)}"
  end
end

BarHeight = 10
BarFullHeight = 11
BarTitleHeight = 13 # 14
BarDetailHeight = 11
BarLabelsLeftMargin = 5
BarLabelsWidth = 120
BarRightMargin = 7
BarPremiumBrandColor = Helper.rgbColor(202, 0, 50)

class BarView < UIView  
  attr_accessor :item
  attr_delegated 'item', :mod, :mods, :index, :comparision
    
  def initWithFrame(frame)
    if super(frame)
      self.opaque = true
      self.backgroundColor = UIColor.whiteColor
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
      modelNameColor = mod.model.premium? ? BarPremiumBrandColor : UIColor.blackColor
      Helper.drawStringInRect mod.model.name, modelRect, modelNameColor, 11, UILineBreakModeClip, UITextAlignmentRight
    end

    Helper.drawStringInRect mod.mod_name, detailRect, UIColor.darkGrayColor, 8, UILineBreakModeClip, UITextAlignmentRight

    bars.each do |bar|
      rect = bar.rect
      oversized = rect.width >= (bounds.width - BarLabelsWidth - 5)
      textWidth = oversized ? (bounds.width - BarLabelsWidth - 12) : rect.width - 4
      textColor = UIColor.whiteColor
      textFont = oversized ? UIFont.boldSystemFontOfSize(9) : UIFont.systemFontOfSize(8)
      bgColors = self.class.colors[bar.index]
      
      Helper.drawGradientRect context, rect, bgColors
      Helper.drawStringInRect bar.text, CGRectMake(rect.x, rect.y - 1, textWidth, rect.height), textColor, textFont, UILineBreakModeClip, UITextAlignmentRight
    end
  end
  
  def self.colors
    @@colors ||= [
      [Helper.rgbColor(0, 90, 180), Helper.rgbColor(108, 164, 220)].reverse,
      [Helper.rgbColor(2, 120, 2), Helper.rgbColor(63, 153, 63)].reverse,
      [Helper.rgbColor(120, 2, 2), Helper.rgbColor(153, 63, 63)].reverse,
      [Helper.rgbColor(2, 2, 120), Helper.rgbColor(63, 63, 153)].reverse,
      [Helper.rgbColor(120, 120, 2), Helper.rgbColor(153, 153, 63)].reverse,
    ]    
  end
end
