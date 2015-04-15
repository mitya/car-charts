class ChartBarView < UIView
  attr_accessor :comparisionItem
  attr_delegated 'comparisionItem', :mod, :mods, :index, :comparision

  TitleLM = KK.iphone?? 2 : 10

  ModelTitleFS = 15.0
  ModelTitleH = KK.lineHeightFromFontSize(ModelTitleFS)
  ModelTitleBM = 0
  ModelTitleRM = 4
  ModTitleFS = 14.0
  ModTitleH = KK.lineHeightFromFontSize(ModTitleFS)
  ModTitleBM = 0

  BarFS = 13.0
  BarH = KK.lineHeightFromFontSize(BarFS)
  BarFH = BarH
  BarLM = TitleLM
  BarRM = TitleLM
  BarValueRM = BarFS / 2
  BarMaxValueRM = BarValueRM + 2
  BarMinW = 90
  BarEmptyW = 38

  WideBarLabelW = 250
  WideBarLM = 5
  WideBarRM = 10
  UltraWideBarLabelW = 350

  FirstItemTM = 5
  ItemBM = KK.iphone?? 5 : 10
  LastItemBM = ItemBM * (KK.iphone?? 2 : 1.5)

  def initWithFrame(frame)
    super
    self.opaque = true
    self.backgroundColor = :white.uicolor
    self.contentMode = UIViewContentModeRedraw
    self
  end

  def drawRect(rect)
    renderingMode = self.class.renderingMode
    renderingMode == :wide || renderingMode == :ultraWide ? drawWide(rect) : drawNarrow(rect)
  end

  def comparisionItem=(item)
    if @comparisionItem != item
      @comparisionItem = item
      setNeedsDisplay
    end
  end

  private

  def drawWide(rect)
    context = UIGraphicsGetCurrentContext()
    headerHeight = 0

    modTitleOptions = comparision.containsOnlyBodyParams?? Mod::NameBodyVersionShortYear : Mod::NameBodyEngineVersionShortYear
    modTitle = mod.modName(modTitleOptions)
    case self.class.renderingMode when :wide
      labelWidth = WideBarLabelW
      labelHeight = ModTitleH
      if comparisionItem.firstForModel?
        headerHeight = ModelTitleH + ModelTitleBM
        modelTitleRect = CGRectMake(0, 0, labelWidth, ModelTitleH)
        KK.drawString mod.model.family.name, inRect:modelTitleRect, withColor:UIColor.blackColor, font:KK.boldFont(ModelTitleFS), alignment:UITextAlignmentRight
      end
      labelRect = CGRectMake(0, headerHeight, labelWidth, labelHeight)
      KK.drawString modTitle, inRect:labelRect, withColor:UIColor.darkGrayColor, font:KK.mainFont(ModTitleFS), alignment:UITextAlignmentRight
    when :ultraWide
      labelWidth = UltraWideBarLabelW
      labelHeight = ModelTitleH
      labelRect = CGRectMake(0, headerHeight, labelWidth, labelHeight)
      KK.drawInRect labelRect, stringsSpecs:[
        [mod.model.family.name, UIColor.blackColor, KK.boldFont(ModelTitleFS), ModelTitleRM],
        [modTitle, UIColor.grayColor, KK.mainFont(ModTitleFS), ModelTitleRM]
      ], alignment:UITextAlignmentRight
    end

    pixelRange = bounds.width - labelWidth - BarMinW - WideBarRM
    textFont = KK.mainFont(BarFS)
    barsOffset = (labelHeight - BarH) / 2 + headerHeight
    textColor = UIColor.whiteColor

    comparision.params.each do |param|
      index = comparision.params.index(param)

      if value = mod.localizedValue(param)
        barWidth = comparision.relativeValueFor(param, value) * pixelRange + BarMinW
        rect = CGRectMake(labelWidth + WideBarLM, barsOffset + index * BarFH, barWidth, BarH)
        isWiderThanBounds = rect.width >= bounds.width - labelWidth
        maxTextWidth = rect.width - (isWiderThanBounds ? BarMaxValueRM : BarValueRM)
        bgColorsIndex = self.class.sessionColorIndexes[index.remainder(self.class.sessionColorIndexes.count)]
        bgColors = self.class.colors[bgColorsIndex]
        textRect = CGRectMake(rect.x, rect.y, maxTextWidth, rect.height)
        text = mod.localizedValueString(param.key)
      else
        rect = CGRectMake(labelWidth + WideBarLM, barsOffset + index * BarFH, BarEmptyW, BarH)
        maxTextWidth = rect.width - (isWiderThanBounds ? BarMaxValueRM : BarValueRM)
        textRect = CGRectMake(rect.x, rect.y, maxTextWidth, rect.height)
        bgColors = self.class.emptyBarColors
        text = 'N/A'
      end

      KK.drawRect rect, inContext:context, withGradientColors:bgColors, cornerRadius:3
      KK.drawString text, inRect:textRect, withColor:textColor, font:textFont, alignment:UITextAlignmentRight
    end
  end

  def drawNarrow(rect)
    context = UIGraphicsGetCurrentContext()
    maxBarWidth = bounds.width - BarLM - BarRM

    topOffset = comparisionItem.first? ? FirstItemTM : 0

    labelRect = CGRectMake(TitleLM, topOffset, maxBarWidth, ModelTitleH)
    modTitleOptions = comparision.containsOnlyBodyParams?? Mod::NameBodyVersionShortYear : Mod::NameBodyEngineVersionShortYear
    modTitle = mod.modName(modTitleOptions)
    modelTitleFSFix = 0
    modTitleFSFix = 0

    if KK.iphone? && KK.portrait?
      modelTitleWidth = mod.model.family.name.sizeWithFont(KK.boldFont(ModelTitleFS)).width
      modTitleWidth = modTitle.sizeWithFont(KK.mainFont(ModelTitleFS)).width
      fullWidth = modelTitleWidth + ModelTitleRM + modTitleWidth
      extraWidth = fullWidth - labelRect.width
      if extraWidth > 0
        extraWidthProportion = labelRect.width / fullWidth
        # modTitleFSFix = extraWidth > 0 ? [extraWidth / 25.0, 2.0].min.round_to(0.1) : 0
        modelTitleFSFix = ModelTitleFS - ModelTitleFS * extraWidthProportion
        modTitleFSFix = ModTitleFS - ModTitleFS * extraWidthProportion
      end
    end

    KK.drawInRect labelRect, stringsSpecs:[
      [mod.model.family.name, UIColor.blackColor, KK.boldFont(ModelTitleFS - modelTitleFSFix), ModelTitleRM],
      [modTitle, UIColor.grayColor, KK.mainFont(ModTitleFS - modTitleFSFix), 0]
    ]

    pixelRange = maxBarWidth - BarMinW
    barsOffset = topOffset + ModelTitleH + ModelTitleBM
    textFont = KK.mainFont(BarFS)
    textColor = UIColor.whiteColor

    comparision.params.each do |param|
      index = comparision.params.index(param)

      if value = mod.localizedValue(param)
        barWidth = comparision.relativeValueFor(param, value) * pixelRange + BarMinW
        rect = CGRectMake(BarLM, barsOffset + index * BarFH, barWidth, BarH)
        isWiderThanBounds = rect.width >= maxBarWidth
        maxTextWidth = rect.width - (isWiderThanBounds ? BarMaxValueRM : BarValueRM)
        textRect = CGRectMake(rect.x, rect.y, maxTextWidth, rect.height)
        bgColorsIndex = self.class.sessionColorIndexes[index.remainder(self.class.sessionColorIndexes.count)]
        bgColors = self.class.colors[bgColorsIndex]
        text = mod.localizedValueString(param.key)
      else
        rect = CGRectMake(BarLM, barsOffset + index * BarFH, BarEmptyW, BarH)
        maxTextWidth = rect.width - (isWiderThanBounds ? BarMaxValueRM : BarValueRM)
        textRect = CGRectMake(rect.x, rect.y, maxTextWidth, rect.height)
        bgColors = self.class.emptyBarColors
        text = 'N/A'
      end

      KK.drawRect rect, inContext:context, withGradientColors:bgColors, cornerRadius:3
      KK.drawString text, inRect:textRect, withColor:textColor, font:textFont, alignment:UITextAlignmentRight
    end
  end


  class << self
    def renderingMode
      case
        when KK.iphone? then :narrow
        when KK.landscape? && KK.app.delegate.chartController.fullScreen? then :ultraWide
        when KK.landscape? || KK.app.delegate.chartController.fullScreen? then :wide
        else :narrow
      end
    end

    def colors
      @colors ||= Metadata.colors.map do |h1,s1,b1,h2,s2,b2|
        [KK.hsb(h1,s1,b1), KK.hsb(h2,s2,b2)]
      end * 5 # there should be more colors than params
    end

    def emptyBarColors
      @emptyBarColors ||= [KK.hsb(0, 0, 80), KK.hsb(0, 0, 70)]
    end

    def heightForComparisionItem(item)
      mode = renderingMode
      height = 0
      height += FirstItemTM if item.first? && mode == :narrow
      height += ChartBarView::ModelTitleH + ChartBarView::ModelTitleBM if mode == :narrow || mode == :wide && item.firstForModel?
      height += item.comparision.params.count * ChartBarView::BarFH
      height += item.lastForModel?? LastItemBM : ItemBM
    end

    def sessionColors
      @sessionColors ||= colors
    end

    def sessionColorsInitialIndexes
      @sessionColorsInitialIndexes ||= (0...colors.length).to_a
    end

    def sessionColorIndexes
      @sessionColorIndexes ||= sessionColorsInitialIndexes.dup
    end

    def adjustSessionColors(removedParamIndex, totalParamsLeft)
      # puts "adjustSessionColors remove #{removedParamIndex}, left #{totalParamsLeft}"
      # puts "adjustSessionColors was #{sessionColorIndexes}"
      
      return if removedParamIndex == totalParamsLeft
      
      firstUnusedParamIndex = totalParamsLeft
      removedParamValue = sessionColorIndexes[removedParamIndex]
      for i in removedParamIndex + 1 .. firstUnusedParamIndex
        sessionColorIndexes[i - 1] = sessionColorIndexes[i]
      end
      sessionColorIndexes[firstUnusedParamIndex] = removedParamValue
      
      # sessionColorIndexes.swap! removedParamIndex, firstUnusedParamIndex
      sessionColorIndexes.sortAsIn! sessionColorsInitialIndexes, from:firstUnusedParamIndex
      sessionColorIndexes.compact!
      
      # puts "adjustSessionColors now #{sessionColorIndexes}"
    end
  end


  class TableCell < UITableViewCell
    attr_accessor :barView
    attr_delegated 'barView', :comparisionItem

    def initWithStyle(style, reuseIdentifier:identifier)
      super UITableViewCellStyleValue1, reuseIdentifier:identifier
      self.barView = ChartBarView.alloc.initWithFrame(CGRectMake(0, 0, contentView.bounds.width, contentView.bounds.height))
      self.barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.contentView.addSubview barView
      self
    end
  end
end
