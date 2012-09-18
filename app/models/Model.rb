# It should be named Model, but the model is already used as a name of the entire model layer.
class Model
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

  def brand
    @brand ||= Brand[key.split("--").first.to_sym]
  end
  
  def selectedModsCount
    Disk.currentMods.select { |mod| mod.model == self }.count
  end
  
  def inspect
    "#<Model:#{key} mods=#{modifications.count}>"
  end
  
  class << self 
    attr_reader :all, :indexByBrandKey
       
    def by(key)
      @index[key]
    end

    def byCategoryKey(categoryKey)
      Metadata.model_classes_inverted[categoryKey].map { |modelKey| self.by(modelKey) }
    end
    
    def byBrandKey(brandKey)
      @indexByBrandKey[brandKey]
    end
    
    # Search by: land, land cruiser, toyota, toyota land, toyota land cruiser
    def searchInCollectionByName(collection, name)
      pattern = /\b#{name.downcase}/i
      collection.select { |m| m.name =~ pattern }
    end

    def keys
      @keys ||= Metadata.model_names.keys.sort
    end
    
    def load
      @all = keys.map { |k| new(k) }
      @index = @all.uniqueIndexBy(&:key)
      @indexByBrandKey = @all.indexBy { |m| m.brand.key }
      @indexByBrandKey.each { |brandKey, models| Brand[brandKey].instance_variable_set(:@models, models) }
    end    
  end  
end
