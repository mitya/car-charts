class Brand
  attr_reader :key
  
  def initialize(key)
    @key = key
  end
  
  def name
    @name ||= Metadata.brand_names[key]
  end

  alias shortName name
  
  def premium?
    self.class.premiumKeys.containsObject(key)
  end  
  
  def inspect
    "{#{key}, #{models.count}}"
  end
  
  def models
    @models ||= ModelGeneration.generationsForBrandKey(key)
  end
  
  def selectedModsCount
    Disk.currentMods.select { |mod| mod.brand == self }.count
  end
  
  def cellImage
    KK.image("brands/#{key}") || Brand.unknownBrandImage
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
    
    def allSortedByName
      @allByName ||= @all.sort_by(&:shortName)
    end
    
    def unknownBrandImage
      KK.image("ci-empty")
    end
  end  
end
