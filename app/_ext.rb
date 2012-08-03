M_PI = Math::PI
YES = true
NO = false
NULL = nil

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