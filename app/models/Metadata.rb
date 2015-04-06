class Metadata
  class << self
    attr_reader :store
    
    def load
      @store = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db/metadata", ofType:"plist"))
    end

    def method_missing(selector, *args, &block)
      case 
        when Statics.has_key?(selector) then Statics[selector]
        when @store.has_key?(selector) then @store[selector]
        else super
      end
    end
    
    def [](key)
      Statics[key] || @store[key]
    end
  end
end
