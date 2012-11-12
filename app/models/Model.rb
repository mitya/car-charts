class Model
  attr_reader :key
  
  def initialize(key)
    @key = key
  end
  
  def name
    metadataRow[1]
  end
  
  def unbrandedName
    metadataRow[0]
  end

  def brandKey
    metadataRow[2].to_sym
  end

  def categoryKey
    metadataRow[3].to_sym
  end

  def brand
    Brand[brandKey]
  end

  def category
    Category[categoryKey]
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
  
  private
  
  def metadataRow
    @metadataRow ||= Metadata[:model_info][key]
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
    def modelsForText(text, inCollection:collection)
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
