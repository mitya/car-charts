class Object
  def presence
    present? ? self : nil
  end
  
  def present?
    !blank?
  end
  
  def blank?
    false
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
  
  def to_proc
    Proc.new { |obj| self === obj }
  end
end


class NilClass
  def blank?
    true
  end
end

class Float
  def round_to(precision)
    (self / precision).round * precision
  end  
end


class Symbol
  def uicolor
    UIColor.send("#{to_s}Color")
  end
end


class NSString
  def blank?
    empty?
  end
  
  PluralizationRules = { }

  def pluralizeFor(count)
    count == 1 ? self : pluralize
  end
  
  def pluralize
    PluralizationRules[self] || self + "s"
  end  
end


class NSNumber
  def blank?
    false
  end
  
  def to_s_or_nil
    self == 0 ? nil : to_s
  end
end


class NSIndexPath
  def inspect
    "{#{section}, #{row}}"
  end
end

class NSURL
  alias inspect description 
  alias to_s description
end
