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
    "{#{x}, #{y}, #{width}, #{height}}"
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
  
  def inspect2
    rgbString || hsbString || whiteLevelString
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

  def setupTableViewWithStyle(tableViewStyle, options = nil)
    offset = options ? options[:offset].to_f : 0.0
    delegate = options && options.include?(:delegate) ? options[:delegate] : self
    bounds = CGRectOffset(view.bounds, 0, offset)
    
    tableView = UITableView.alloc.initWithFrame(bounds, style:tableViewStyle)
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    tableView.dataSource = delegate
    tableView.delegate = delegate
    view.addSubview(tableView)
    tableView
  end
  
  def realWidth
    controller = tabBarController || navigationController || self
    controller.view.bounds.width
  end
  
  def isViewVisible
    isViewLoaded && view.window
  end
  
  def presentNavigationController(controller)
    modalNavController = UINavigationController.alloc.initWithRootViewController(controller)
    modalNavController.navigationBar.barStyle = UIBarStyleBlack
    modalNavController.toolbar.barStyle = UIBarStyleBlack
    # modalNavController.modalPresentationStyle = UIModalPresentationFullScreen
    # modalNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve
    presentViewController modalNavController, animated:YES, completion:NIL
  end
end

class UITableView
  def dequeueReusableCell(options = nil, &block)
    klass = options && options[:klass] || UITableViewCell
    style = options && options[:style] || UITableViewCellStyleDefault
    id = options && options[:id] || "cell"
    
    cell = dequeueReusableCellWithIdentifier(id) || klass.alloc.initWithStyle(style, reuseIdentifier:id).tap do |cell|
      cell.textLabel.backgroundColor = UIColor.clearColor if klass == DSBadgeViewCell
      block.call(cell) if block
    end
  end
  
  def reloadVisibleRows
    reloadRowsAtIndexPaths(indexPathsForVisibleRows, withRowAnimation:UITableViewRowAnimationNone)
  end
end

class UITableViewCell
  def toggleLeftCheckmarkAccessory(options = {})
    wasChecked = imageView.image == UIImage.imageNamed("list_checkmark")
    imageView.image = UIImage.imageNamed(wasChecked ? "list_checkmark_stub" : "list_checkmark")
    textLabel.textColor = wasChecked ? UIColor.darkTextColor : ES.checkedTableViewItemColor if options[:textColor] != NO
    wasChecked
  end
  
  def toggleCheckmarkAccessory
    wasChecked = accessoryType == UITableViewCellAccessoryCheckmark
    textLabel.textColor = wasChecked ? UIColor.darkTextColor : ES.checkedTableViewItemColor
    self.accessoryType = wasChecked ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark
    wasChecked
  end
end

class UITabBarController
  def setTabBarHidden(hidden, animated:animated)
    duration = animated ? 0.2 : 0
    contentHeight = hidden ? view.bounds.height : view.bounds.height - tabBar.bounds.height
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
SafariUA = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7"
DSToolbarHeight = 44.0
