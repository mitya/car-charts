class Brand
  attr_reader :key
  
  def initialize(key)
    @key = key
  end
  
  def name
    @name ||= Metadata.brand_names[key]
  end
  
  def premium?
    self.class.premiumKeys.containsObject(key)
  end  
  
  def inspect
    "{#{key}, #{models.count}}"
  end
  
  def models
    @models ||= ModelGeneration.generationsForBrandKey(key)
  end
  
  class << self 
    attr_reader :index, :all
       
    def [](key)
      @index[key]
    end

    def keys
      @keys ||= Metadata.brand_names.keys.sort
    end
    
    def premiumKeys
      @premiumKeys ||= NSSet.setWithArray(Metadata.premiumBrandKeys)
    end
    
    def load
      @all = keys.map { |key| new(key) }
      @index = @all.uniqueIndexBy(&:key)
    end    
  end  
end
