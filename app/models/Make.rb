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
    @unbrandedName ||= Metadata.model_names
  end
  
  def brandKey
    @brandKey ||= @key.split("--").first
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
    def get(key)
      @@map[key] ||= new(key)
    end

    def getMany(keys)
      keys.map { |k| get(k) }
    end

    def inCategory(categoryKey)
      getMany Metadata.model_classes_inverted[categoryKey]
    end

    def allKeys
      @@allKeys ||= Metadata.model_names.keys.sort
    end  

    def all
      @@all ||= self.getMany(allKeys)
    end
    
    def premiumBrandKeys
      @@premiumBrandKeys ||= NSSet.setWithArray(Metadata.premiumBrandKeys)
    end    

    @@map = {}    
  end  
end
