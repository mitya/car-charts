class BarTableViewCell < UITableViewCell
  attr_accessor :barView
  attr_delegated 'barView', :comparisionItem
  
  def initWithStyle(style, reuseIdentifier:identifier)
    super UITableViewCellStyleValue1, reuseIdentifier:identifier
    self.barView = BarView.alloc.initWithFrame(CGRectMake(0, 0, contentView.bounds.width, contentView.bounds.height))
    self.barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.contentView.addSubview barView
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
  attr_accessor :comparisionItem
  attr_delegated 'comparisionItem', :mod, :mods, :index, :comparision

  def initWithFrame(frame)
    super
    self.opaque = true
    self.backgroundColor = UIColor.whiteColor # ES.patternColor("bg-chart")
    self.contentMode = UIViewContentModeRedraw
    self
  end

  # BarHeight = 10
  # BarHeightWithMargins = BarHeight + 1  
  # BarTitleHeight = 13 # 14
  # BarDetailHeight = 11
  # BarLabelsLeftMargin = 5
  # BarLabelsWidth = 120
  # BarRightMargin = 7
  # BarPremiumBrandColor = ES.rgb(202, 0, 50)
  # 
  # def draw1(rect)
  #   context = UIGraphicsGetCurrentContext()
  #   
  #   labelWidth = bounds.width * 0.4    
  # 
  #   minWidth = 40
  #   pixelRange = bounds.width - labelWidth - BarLabelsLeftMargin - minWidth - BarRightMargin
  #   
  #   bars = comparision.params.map do |param|
  #     firstBarShift = comparisionItem.firstForModel?? BarTitleHeight : 0
  # 
  #     bar = BarViewInfo.new
  #     bar.index = comparision.params.index(param)
  #     bar.param = param
  #     bar.mod = mod
  #     bar.width = (bar.value - comparision.minValueFor(param)) * pixelRange / comparision.rangeFor(param) + minWidth
  #     bar.rect = CGRectMake(labelWidth + 10, 1 + firstBarShift + bar.index * BarFullHeight, bar.width, BarHeight)
  #     bar
  #   end
  #   
  #   modelRect = CGRectMake(BarLabelsLeftMargin, 0, labelWidth, BarHeight)
  #   detailRect = CGRectMake(BarLabelsLeftMargin, comparisionItem.first?? BarTitleHeight : 0, labelWidth, BarDetailHeight)
  # 
  #   if comparisionItem.firstForModel?
  #     modelNameColor = UIColor.blackColor # mod.model.brand.premium? ? BarPremiumBrandColor : UIColor.blackColor
  #     ES.drawStringInRect mod.model.name, modelRect, modelNameColor, 11, UILineBreakModeClip, UITextAlignmentRight
  #   end
  # 
  #   modTitle = comparision.containsOnlyBodyParams?? mod.version : mod.modName
  #   ES.drawStringInRect modTitle, detailRect, UIColor.darkGrayColor, 8, UILineBreakModeClip, UITextAlignmentRight
  # 
  #   bars.each do |bar|
  #     rect = bar.rect
  #     oversized = rect.width >= (bounds.width - labelWidth - 5)
  #     textWidth = oversized ? (bounds.width - labelWidth - 12) : rect.width - 4
  #     textColor = UIColor.whiteColor
  #     textFont = oversized ? UIFont.boldSystemFontOfSize(9) : UIFont.systemFontOfSize(8)
  #     bgColors = self.class.colors[bar.index.remainder(self.class.colors.count)]
  #     
  #     ES.drawGradientRect context, rect, bgColors
  #     ES.drawStringInRect bar.text, CGRectMake(rect.x, rect.y - 1, textWidth, rect.height), textColor, textFont, UILineBreakModeClip, UITextAlignmentRight
  #   end    
  # end

  # ModelTitleH = 16
  # ModelTitleBM = 0
  # ModTitleH = 16
  # ModTitleBM = 0

  TitleLM = 4

  ModelTitleFS = 15.0
  ModelTitleH = ESLineHeightFromFontSize(ModelTitleFS)
  ModelTitleBM = 0
  ModelTitleRM = 4
  ModTitleFS = 13.0
  ModTitleH = ESLineHeightFromFontSize(ModTitleFS)
  ModTitleBM = 0
    
  BarFS = 13.0
  BarH = ESLineHeightFromFontSize(BarFS)
  BarFH = BarH + 0
  BarLM = TitleLM
  BarRM = 1 # -2
  BarValueRM = BarFS / 2
  BarMaxValueRM = BarValueRM + 2

  def draw2(rect)
    context = UIGraphicsGetCurrentContext()
    
    labelWidth = 0
    minWidth = 40
    maxBarWidth = bounds.width - BarLM - BarRM
    pixelRange = maxBarWidth - minWidth
    
    # barsOffset = ModTitleH + ModTitleBM
    # barsOffset += ModelTitleH + ModelTitleBM if comparisionItem.firstForModel?

    barsOffset = ModelTitleH + ModelTitleBM
    bars = comparision.params.map do |param|
      bar = BarViewInfo.new
      bar.index = comparision.params.index(param)
      bar.param = param
      bar.mod = mod
      bar.width = (bar.value - comparision.minValueFor(param)) * pixelRange / comparision.rangeFor(param) + minWidth
      bar.rect = CGRectMake(BarLM, barsOffset + bar.index * BarFH, bar.width, BarH)
      bar
    end
    
    # if comparisionItem.firstForModel?
    #   modelTitleRect = CGRectMake(TitleLM, 0, maxBarWidth, ModelTitleH)
    #   ES.drawString mod.model.name, inRect:modelTitleRect, withColor:'black', font:ES.boldFont(13), alignment:UITextAlignmentLeft
    # end
    # 
    # modTitleRect = CGRectMake(TitleLM, modelTitleRect ? ModelTitleH + ModelTitleBM : 0, maxBarWidth, ModTitleH)
    # ES.drawString mod.basicName, inRect:modTitleRect, withColor:ES.grayTextColor, font:ES.mainFont(13), alignment:UITextAlignmentLeft


    titleRect = CGRectMake(TitleLM, 0, maxBarWidth, ModelTitleH)
    ES.drawInRect titleRect, stringsSpecs:[
      [mod.model.name, UIColor.blackColor, ES.boldFont(ModelTitleFS), ModelTitleRM],
      [mod.basicName, ES.grayTextColor, ES.mainFont(ModTitleFS), 0]
    ]


    # if comparisionItem.firstForModel?
    #   titleRect = CGRectMake(TitleLM, 0, maxBarWidth, ModTitleH)
    #   ES.drawInRect titleRect, stringsSpecs:[
    #     [mod.model.name, UIColor.blackColor, ES.boldFont(13), 4],
    #     [mod.basicName, ES.grayTextColor, ES.mainFont(13), 0]
    #   ]
    # else
    #   modTitleRect = CGRectMake(TitleLM, 0, maxBarWidth, ModTitleH)
    #   ES.drawString mod.basicName, inRect:modTitleRect, withColor:ES.grayTextColor, font:ES.mainFont(13), alignment:UITextAlignmentLeft
    # end

    bars.each do |bar|
      rect = bar.rect
      isWiderThanBounds = rect.width >= maxBarWidth
      maxTextWidth = rect.width - (isWiderThanBounds ? BarMaxValueRM : BarValueRM)
      textFont = ES.mainFont(BarFS)
      textRect = CGRectMake(rect.x, rect.y, maxTextWidth, rect.height)
      bgColors = self.class.colors[bar.index.remainder(self.class.colors.count)]
            
      ES.drawRect rect, inContext:context, withGradientColors:bgColors, cornerRadius:3
      ES.drawString bar.text, inRect:textRect, withColor:'white', font:textFont, alignment:UITextAlignmentRight
    end    
  end

  def drawRect(rect)
    draw2(rect)
  end
  
  def self.colors
    @colors ||= Metadata.colors.map do |h,s,b|
      [ES.hsb(h, s - 20, b + 5), ES.hsb(h, s + 10, b - 5)]
    end
  end
end
