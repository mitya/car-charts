class Model
  attr_reader :key
  
  def initialize(key)
    @key = key
  end
  
  def name
    @name ||= Metadata[:model_info][key][1]
  end
  
  def unbrandedName
    @unbrandedName ||= Metadata[:model_info][key][0]
  end

  def brand
    @brand ||= Brand[key.split("--").first.to_sym]
  end
  
  def selectedModsCount
    Disk.currentMods.select { |mod| mod.model == self }.count
  end
  
  def mods
    Mod.modsForModelKey(key)
  end
  
  def inspect
    "#<Model:#{key} mods=#{mods.count}>"
  end
  
  class << self 
    attr_reader :all
       
    def modelForKey(key)
      @index[key]
    end

    def modelsForCategoryKey(categoryKey)
      Metadata[:models_by_class][categoryKey].map { |k| modelForKey(k) }
    end
    
    def modelsForBrandKey(brandKey)
      Metadata[:models_by_brand][brandKey].map { |k| modelForKey(k) }
    end
    
    # Search by: land, land cruiser, toyota, toyota land, toyota land cruiser
    def modelsInCollectionForText(collection, text)
      pattern = /\b#{text.downcase}/i
      collection.select { |m| m.name =~ pattern }
    end

    def keys
      @keys ||= Metadata[:model_keys]
    end
    
    def load
      @all = keys.map { |k| new(k) }
      @index = @all.uniqueIndexBy(&:key)
    end    
  end  
  
  class IndexByBrand
    def [](brandKey)
      Model.modelsForBrandKey(brandKey)
    end
    
    def keys
      Brand.keys
    end
  end
end
