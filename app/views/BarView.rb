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

class BarView < UIView  
  attr_accessor :comparisionItem
  attr_delegated 'comparisionItem', :mod, :mods, :index, :comparision

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
  BarRM = 1
  BarValueRM = BarFS / 2
  BarMaxValueRM = BarValueRM + 2
  
  WideBarLabelW = 250
  WideBarLM = 5
  WideBarRM = 10

  def initWithFrame(frame)
    super
    self.opaque = true
    self.backgroundColor = UIColor.whiteColor # ES.patternColor("bg-chart")
    self.contentMode = UIViewContentModeRedraw
    self
  end

  def drawWide(rect)
    context = UIGraphicsGetCurrentContext()
    labelWidth = WideBarLabelW
    
    if comparisionItem.firstForModel?
      modelTitleRect = CGRectMake(0, 0, labelWidth, ModelTitleH)      
      ES.drawString mod.model.name, inRect:modelTitleRect, withColor:UIColor.blackColor, font:ModelTitleFS, alignment:UITextAlignmentRight 
    end
    
    modTitleOffset = comparisionItem.firstForModel?? ModelTitleH : 0
    modTitleRect = CGRectMake(0, modTitleOffset, labelWidth, ModTitleH)
    modTitle = comparision.containsOnlyBodyParams?? mod.version : mod.modName
    ES.drawString modTitle, inRect:modTitleRect, withColor:UIColor.darkGrayColor, font:ModTitleFS, alignment:UITextAlignmentRight    
    
    minBarWidth = 40
    maxBarWidth = bounds.width - WideBarLM - WideBarRM
    pixelRange = bounds.width - labelWidth - minBarWidth - WideBarRM
    comparision.params.each do |param|
      firstBarShift = comparisionItem.firstForModel?? ModelTitleH : 0
      
      bar = Info.new
      bar.index = comparision.params.index(param)
      bar.param = param
      bar.mod = mod
      bar.width = (bar.value - comparision.minValueFor(param)) * pixelRange / comparision.rangeFor(param) + minBarWidth
      bar.rect = CGRectMake(labelWidth + WideBarLM, 1 + firstBarShift + bar.index * BarFH, bar.width, BarH)

      rect = bar.rect
      isWiderThanBounds = rect.width >= bounds.width - labelWidth
      maxTextWidth = rect.width - (isWiderThanBounds ? BarMaxValueRM : BarValueRM)
      textColor = UIColor.whiteColor
      textFont = ES.mainFont(BarFS)
      bgColors = self.class.colors[bar.index.remainder(self.class.colors.count)]
      textRect = CGRectMake(rect.x, rect.y - 1, maxTextWidth, rect.height)
      
      ES.drawRect rect, inContext:context, withGradientColors:bgColors, cornerRadius:3
      ES.drawString bar.text, inRect:textRect, withColor:textColor, font:textFont, alignment:UITextAlignmentRight
    end    
  end

  def drawNarrow(rect)
    context = UIGraphicsGetCurrentContext()    
    labelWidth = 0
    minWidth = 40
    maxBarWidth = bounds.width - BarLM - BarRM
    pixelRange = maxBarWidth - minWidth
    barsOffset = ModelTitleH + ModelTitleBM

    titleRect = CGRectMake(TitleLM, 0, maxBarWidth, ModelTitleH)
    ES.drawInRect titleRect, stringsSpecs:[
      [mod.model.name, UIColor.blackColor, ES.boldFont(ModelTitleFS), ModelTitleRM],
      [mod.basicName, ES.grayTextColor, ES.mainFont(ModTitleFS), 0]
    ]

    bars = comparision.params.map do |param|
      bar = Info.new
      bar.index = comparision.params.index(param)
      bar.param = param
      bar.mod = mod
      bar.width = (bar.value - comparision.minValueFor(param)) * pixelRange / comparision.rangeFor(param) + minWidth
      bar.rect = CGRectMake(BarLM, barsOffset + bar.index * BarFH, bar.width, BarH)
      bar
    end
    
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
    # drawNarrow(rect)
    drawWide(rect)
  end
  
  def self.colors
    @colors ||= Metadata.colors.map do |h,s,b|
      [ES.hsb(h, s - 20, b + 5), ES.hsb(h, s + 10, b - 5)]
    end
  end

  class Info
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
end
