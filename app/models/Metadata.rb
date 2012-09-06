class Metadata
  class << self
    def load
      @store = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db-metadata", ofType:"plist"))
    end

    def method_missing(selector, *args, &block)
      case 
        when StaticData.has_key?(selector.to_sym) then StaticData[selector.to_sym]
        when @store.has_key?(selector) then @store[selector]
        else super
      end
    end
    
    def [](key)
      StaticData[key] || @store[key]
    end
  end
end
