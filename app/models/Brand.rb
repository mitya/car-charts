class Brand
  attr_reader :key
  
  def initialize(key)
    @key = key
  end
  
  def name
    @name ||= Metadata.brandNames[key]
  end
  
  def premium?
    self.class.premiumKeys.containsObject(key)
  end  
  
  def inspect
    "#<Brand:#{key} models=#{models.count}>"
  end
  
  def models
    @models ||= Model.modelsForBrandKey(key)
  end
  
  class << self 
    attr_reader :index, :all
       
    def [](key)
      @index[key]
    end

    def keys
      @keys ||= Metadata.brandNames.keys
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
