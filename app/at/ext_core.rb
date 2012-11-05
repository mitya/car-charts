M_PI = Math::PI
YES = true
NO = false
NONE = NO
NULL = nil

class Object
  def presence
    self == nil || self == "" || self == [] ? nil : self 
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

class NSString
  def blank?
    empty?
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
  
  def tail
    self[1..-1]
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
  
  def uniqBy
    uniqObjects = []
    uniqKeys = []
    each do |object|
      key = yield(object)
      if !uniqKeys.include?(key)
        uniqObjects << object
        uniqKeys << key
      end
    end
    uniqObjects
  end
  
  def arraySeparatedBy(separator)
    empty? ? [] : [separator] + flat_map { |obj| [obj, separator] }
  end
  
  def pluck(method)
    map { |obj| obj.send(method) }
  end
  
  def swap(i, j)
    a, b = self[i], self[j]
    self[i], self[j] = b, a
    self
  end
end

class NSDictionary
  def symbolizeKeys
    copy = {}
    each_pair { |key, value| copy[key.to_sym] = value }
    copy
  end  
  
  def objectForIndexPath(indexPath)
    key = keys[indexPath.section]
    object = self[key][indexPath.row]
    object
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

class NSIndexPath
  def inspect
    "{#{section}, #{row}}"
  end
end
