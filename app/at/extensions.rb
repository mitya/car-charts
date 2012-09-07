M_PI = Math::PI
YES = true
NO = false
NULL = nil

class NSArray
  def copyWithToggled(item)
    if include?(item)
      self - [item]
    else
      self + [item]
    end
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
  def toggleCheckmark
    if self.accessoryType == UITableViewCellAccessoryCheckmark
      self.accessoryType = UITableViewCellAccessoryNone
      true
    else
      self.accessoryType = UITableViewCellAccessoryCheckmark
      false
    end    
  end
end
