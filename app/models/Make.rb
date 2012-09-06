# It should be named Model, but the model is already used as a name of the entire model layer.
class Make
  attr_reader :key, :modifications
  
  def initialize(key)
    @key = key
    @modifications = []
  end
  
  def name
    @name ||= Model.metadata['model_names_branded'][key]
  end
  
  def unbrandedName
    @unbrandedName ||= Model.metadata['model_names']
  end
  
  def brandKey
    @brandKey ||= @key.split("--").first
  end
  
  def selectedModsCount
    Model.currentMods.select { |mod| mod.model == self }.count
  end
  
  def premium?
    Model.premiumBrandKeys.containsObject(brandKey)
  end  
  
  class << self
    def get(key)
      @@map[key] ||= new(key)
    end

    def getMany(keys)
      keys.map { |k| get(k) }
    end

    def inCategory(categoryKey)
      getMany Model.metadata['model_classes_inverted'][categoryKey]
    end

    def allKeys
      @@allKeys ||= Model.metadata['model_names'].keys.sort
    end  

    def all
      @@all ||= self.getMany(allKeys)
    end

    @@map = {}    
  end  
end
