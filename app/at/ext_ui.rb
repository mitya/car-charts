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

class UIFont
  def inspect
    "#<#{self.class.name}:'#{fontName}' #{pointSize}/#{lineHeight}>"
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

class UIViewController
  def self.new(*args)
    alloc.init.tap { |this| this.send(:initialize, *args) if this.respond_to?(:initialize, true) }
  end

  def setupTableViewWithStyle(tableViewStyle)
    tableView = UITableView.alloc.initWithFrame(view.bounds, style:tableViewStyle)
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    tableView.dataSource = self
    tableView.delegate = self
    view.addSubview(tableView)
    tableView
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
  def toggleLeftCheckmarkAccessory
    wasChecked = imageView.image == UIImage.imageNamed("list_checkmark")
    imageView.image = UIImage.imageNamed(wasChecked ? "list_checkmark_stub" : "list_checkmark")
    textLabel.textColor = wasChecked ? UIColor.darkTextColor : ES.checkedTableViewItemColor
    wasChecked
  end
  
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

class UITabBarController
  def setTabBarHidden(hidden, animated:animated)
    duration = animated ? 0.2 : 0
    contentHeight = hidden ? 480 : 431 # 271
    ES.animateWithDuration(duration) do
      view.subviews.each do |view|
        if view.isKindOfClass(UITabBar)
          view.frame = CGRectMake(view.frame.origin.x, contentHeight, view.frame.size.width, view.frame.size.height)
        else 
          view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, contentHeight)
        end
      end      
    end    
  end
end

class UIView
  def xdBorder(color = UIColor.redColor)
    ES.setDevBorder(self, color)
  end
  
  def setRoundedCornersWithRadius(radius, width:width, color:color)
    ES.setRoundedCornersForView(self, withRadius:radius, width:width, color:color)
  end
end

UIViewAutoresizingFlexibleAllMargins = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
