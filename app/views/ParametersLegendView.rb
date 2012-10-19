class ParametersLegendView < UIView
  attr_accessor :parameters

  ContainerVM = 10
  ContainerHM = 10
  ItemFS = 14.0
  ItemH = ESLineHeightFromFontSize(ItemFS)
  ItemVM = 2
  ItemRM = ItemFS / 2
  ItemFH = ItemH + ItemVM
  ColorH = ItemH * 0.9
  ColorW = ColorH * 1.5
  ColorRM = 3

  def initialize(parameters)
    initWithFrame CGRectMake(0, 0, 0, parameters.count * 25 + 10)
    
    self.parameters = parameters
    self.backgroundColor = UIColor.whiteColor

    layer.borderColor = ES.separatorColor.CGColor
    layer.borderWidth = 1.0
    layer.cornerRadius = 10
    layer.masksToBounds = true
  end
  
  def parameters=(array)
    @parameters = array

    subviews.each { |view| view.removeFromSuperview }
    @parameters.each_with_index { |param, index| addSubview Item.new(param, index) }

    setNeedsDisplay
  end
  
  def drawRect(rect)
    rows = [[]]
    x, y = ContainerHM, ContainerVM
    subviews.select(&Item).each_with_index do |item, index|
      item.sizeToFit
      fitsInRow = x + item.bounds.width + ItemRM <= bounds.width - ContainerHM
      if !fitsInRow
        x, y = ContainerHM, y + ItemFH 
        rows << []
      end
      item.frame = CGRectMake(x, y, item.bounds.width, item.bounds.height)
      rows.last << item
      x += item.bounds.width + ItemRM
    end
    
    rows.each do |row|
      rowWidth = row.reduce(0) { |width, item| width + item.bounds.width } + ItemRM * (row.count - 1)
      spacing = (bounds.width - ContainerHM * 2 - rowWidth) / row.count
      row.each_with_index { |item, index| item.frame = CGRectOffset(item.frame, index * spacing + spacing * 0.5, 0) }
    end
    
    self.frame = CGRectMake(frame.x, frame.y, frame.width, y + ItemFH + ContainerVM)
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

