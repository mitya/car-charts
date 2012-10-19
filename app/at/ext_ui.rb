class CGRect
  def x
    origin.x
  end

  def y
    origin.y
  end

  def width
    size.width
  end

  def height
    size.height
  end
  
  def rectWithHorizMargins(margin)
    CGRectMake(x + margin, y, width - margin * 2, height)
  end
  
  def inspect
    "<CGRect #{x}, #{y}, #{width}, #{height}>"
  end
end

###############################################################################

class UIColor
  def hsbString
    hue, saturation, brightness, alpha = Pointer.new(:float), Pointer.new(:float), Pointer.new(:float), Pointer.new(:float)
    success = getHue(hue, saturation:saturation, brightness:brightness, alpha:alpha)
    success ? "hsba(%.2f, %.2f, %.2f, %.2f)" % [hue, saturation, brightness, alpha].map(&:value) : nil
  end
    
  def rgbString
    red, green, blue, alpha = Pointer.new(:float), Pointer.new(:float), Pointer.new(:float), Pointer.new(:float)
    success = getRed(red, green:green, blue:blue, alpha:alpha)
    success ? "rgba(%.2f, %.2f, %.2f, %.2f)" % [red, green, blue, alpha].map(&:value) : nil
  end
    
  def whiteLevelString
    white, alpha = Pointer.new(:float), Pointer.new(:float)
    success = getWhite(white, alpha:alpha)
    success ? "white(%.2f, alpha=%.2f)" % [white, alpha].map(&:value) : nil
  end  
end

class UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStylePlain
  
  def self.initAsRubyObject(*args)
    style = const_get(:DefaultTableViewStyleForRubyInit)    
    alloc.initWithStyle(style).tap { |this| this.send(:initialize, *args) }
  end
  
  def self.new(*args)
    initAsRubyObject(*args)
  end  
end

class UITableView
  def dequeueReusableCell(options = nil)
    klass = options && options[:klass] || UITableViewCell
    style = options && options[:style] || UITableViewCellStyleDefault
    id = options && options[:id] || "cell"

    unless cell = dequeueReusableCellWithIdentifier(id)
      cell = klass.alloc.initWithStyle(style, reuseIdentifier:id)
      cell.textLabel.backgroundColor = UIColor.clearColor if klass == DSBadgeViewCell
      yield cell if block_given?
    end
    
    cell    
  end
end

class UITableViewCell
  def toggleCheckmarkAccessory
    if self.accessoryType == UITableViewCellAccessoryCheckmark
      self.accessoryType = UITableViewCellAccessoryNone
      true
    else
      self.accessoryType = UITableViewCellAccessoryCheckmark
      false
    end    
  end
end

class UIView
  def xdBorder
    ES.setDevBorder(self)
  end
end

UIViewAutoresizingFlexibleAllMargins = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
