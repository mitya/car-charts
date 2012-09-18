M_PI = Math::PI
YES = true
NO = false
NULL = nil

###############################################################################

class Class
  def attr_delegated(target, *attrs)
    @attrs_delegated ||= {}
    methods = attrs + attrs.map { |atr| "#{atr}=".to_sym }
    methods.each { |method| @attrs_delegated[method] = target }
    
    extmod = Module.new do
      def method_missing(selector, *args, &block)
        metadata = self.class.instance_variable_get(:@attrs_delegated)
        target = metadata[selector] && send(metadata[selector])
        if target
          target.send(selector, *args) if target
        else
          super
        end        
      end      
    end
    
    include(extmod)
  end  
end

###############################################################################

class NSArray
  def dupWithToggledObject(item)
    if include?(item)
      self - [item]
    else
      self + [item]
    end
  end

  def uniqueIndexBy
    index = {}
    each { |object| index[yield(object)] = object }
    index
  end
    
  def indexBy
    index = {}
    each do |object|
      key = yield(object)
      index[key] ||= []
      index[key] << object
    end
    index
  end
end

class NSDictionary
  def symbolizeKeys
    copy = {}
    each_pair { |key, value| copy[key.to_sym] = value }
    copy
  end  
end

class NSMutableDictionary
  def symbolizeKeys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end  
end

class NSString
  PluralizationRules = { }

  def pluralizeFor(count)
    count == 1 ? self : pluralize
  end
  
  def pluralize
    PluralizationRules[self] || self + "s"
  end
end

###############################################################################

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
  
  def withHMargins(margin)
    CGRectMake(x + margin, y, width - margin * 2, height)
  end
  
  def inspect
    "<CGRect #{x}, #{y}, #{width}, #{height}>"
  end
end

###############################################################################

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
  def dequeueReusableCell(options = {})
    klass = options[:klass] || UITableViewCell
    style = options[:style] || UITableViewCellStyleDefault 
    id = options[:id] || "cell"

    unless cell = dequeueReusableCellWithIdentifier(id)
      cell = klass.alloc.initWithStyle(style, reuseIdentifier:id)
      cell.textLabel.backgroundColor = UIColor.clearColor if klass == BadgeViewCell
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
