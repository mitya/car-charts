class Metadata
  class << self
    attr_reader :store
    
    def load
      @store = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db-metadata", ofType:"plist"))
    end

    def method_missing(selector, *args, &block)
      case 
        when StaticData.has_key?(selector) then StaticData[selector]
        when @store.has_key?(selector) then @store[selector]
        else super
      end
    end
    
    def [](key)
      StaticData[key] || @store[key]
    end
    
    def brandNamesList
      @brandNamesList ||= brandNames.values
    end
    
    def brandKeys
      @brandKeys ||= brandNames.keys
    end
  end
end
