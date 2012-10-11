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
  
  def modifications
    Mod.byModelKey(key)
  end
  
  def inspect
    "#<Model:#{key} mods=#{modifications.count}>"
  end
  
  class << self 
    attr_reader :all
       
    def by(key)
      @index[key]
    end

    def byCategoryKey(categoryKey)
      Metadata[:models_by_class][categoryKey].map { |modelKey| by(modelKey) }
    end
    
    def byBrandKey(brandKey)
      Metadata[:models_by_brand][brandKey].map { |modelKey| by(modelKey) }
    end
    
    # Search by: land, land cruiser, toyota, toyota land, toyota land cruiser
    # def modelsInCollectionForName(collection, name)
    def searchInCollectionByName(collection, name)
      pattern = /\b#{name.downcase}/i
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
      Model.byBrandKey(brandKey)
    end
    
    def keys
      Brand.keys
    end
  end
end
