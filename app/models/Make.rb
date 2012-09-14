# It should be named Model, but the model is already used as a name of the entire model layer.
class Make
  attr_reader :key, :modifications
  
  def initialize(key)
    @key = key
    @modifications = []
  end
  
  def name
    @name ||= Metadata.model_names_branded[key]
  end
  
  def unbrandedName
    @unbrandedName ||= Metadata.model_names[key]
  end
  
  def brandKey
    @brandKey ||= @key.split("--").first.to_sym
  end
  
  def selectedModsCount
    Model.currentMods.select { |mod| mod.model == self }.count
  end
  
  def premium?
    self.class.premiumBrandKeys.containsObject(brandKey)
  end  
  
  def inspect
    "#<Make:#{key} mods=#{modifications.count}>"
  end
  
  class << self 
    attr_reader :map, :all, :indexByBrand
       
    def get(key)
      @map[key] ||= new(key)
    end

    def getMany(keys)
      keys.map { |k| get(k) }
    end

    def byCategoryKey(categoryKey)
      getMany Metadata.model_classes_inverted[categoryKey]
    end
    
    def byBrandKey(brandKey)
      @indexByBrand[brandKey]
    end

    def keys
      @keys ||= Metadata.model_names.keys.sort
    end
    
    def premiumBrandKeys
      @premiumBrandKeys ||= NSSet.setWithArray(Metadata.premiumBrandKeys)
    end
    
    def load
      @map = {}
      @all = getMany(keys)
      @indexByBrand = all.indexBy(&:brandKey)
    end    
  end  
end
