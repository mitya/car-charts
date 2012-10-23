class ParametersLegendView < UIView
  attr_accessor :parameters, :content

  ContentTM = 8
  ContentTP = 16
  ContentBM = 8
  ContentHM = 5
  ItemFS = 13.0
  ItemH = ESLineHeightFromFontSize(ItemFS)
  ItemVM = 1
  ItemRM = ItemFS / 2
  ItemFH = ItemH + ItemVM
  ColorH = ItemH * 1.0
  ColorW = ColorH * 3
  ColorRM = 3

  def initialize(parameters)
    initWithFrame CGRectMake(0, 0, 0, parameters.count * ItemFH + ContentTM + ContentTP + ContentBM)
    
    self.content = UIView.alloc.initWithFrame(CGRectMake(ContentHM, ContentTM, UIScreen.mainScreen.bounds.width - ContentHM*2, frame.height))
    addSubview(content)

    topBorder = CALayer.layer
    topBorder.frame = CGRectMake(0, 0, content.frame.width, 1)
    topBorder.backgroundColor = ES.separatorColor.CGColor
    content.layer.addSublayer(topBorder)

    self.parameters = parameters
    self.backgroundColor = UIColor.whiteColor
  end
  
  def parameters=(array)
    @parameters = array

    @content.subviews.each { |view| view.removeFromSuperview }
    @parameters.each_with_index { |param, index| @content.addSubview Item.new(param, index) }

    setNeedsDisplay
  end
  
  def drawRect(rect)
    options = {containerHM:0, containerTM:ContentTP, viewFH:ItemFH}
    viewsBottomEdge = ES.alignBlockViews content.subviews.select(&Item), inContainer:content, withOptions:options
    content.frame = CGRectMake(content.frame.x, content.frame.y, content.frame.width, viewsBottomEdge)
    self.frame = CGRectMake(frame.x, frame.y, frame.width, content.frame.height + ContentTM + ContentBM)
  end
  
  class Item < UIView
    attr_accessor :param, :index

    def initialize(param, index)
      initWithFrame CGRectNull
      self.backgroundColor = UIColor.whiteColor
      @param = param
      @index = index
    end

    def drawRect(rect)
      context = UIGraphicsGetCurrentContext()
      colorGradient = BarView.colors[index]
      colorFrame = CGRectMake(0, (ItemH - ColorH) / 2.0, ColorW, ColorH)
      textSize = param.name.sizeWithFont(textFont)
      textFrame  = CGRectMake(ColorW + ColorRM, (ItemH - textSize.height) / 2.0, textSize.width, textSize.height)
      ES.drawRect colorFrame, inContext:context, withGradientColors:colorGradient, cornerRadius:3
      ES.drawString param.name, inRect:textFrame, withColor:UIColor.darkGrayColor, font:textFont, alignment:UITextAlignmentLeft
    end

    def sizeThatFits(oldSize)
      size = param.name.sizeWithFont(textFont)
      CGSizeMake(size.width + ColorW + ColorRM, ItemH)
    end
    
    def textFont
      UIFont.systemFontOfSize(ItemFS)
    end
  end
end

