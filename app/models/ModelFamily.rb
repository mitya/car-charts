class ModelFamily
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
    metadataRow[2]
  end

  def categoryKey
    metadataRow[3]
  end

  def brand
    Brand[brandKey]
  end

  def category
    Category[categoryKey]
  end

  def selectedModsCount
    Disk.currentMods.select { |mod| mod.family == self }.count
  end

  def generations
    metadataRow[4].map { |generation_key| ModelGeneration[generation_key] }
  end
  
  def mods
    Mod.modsForFamilyKey(key)
  end
  
  def inspect
    "{family:#{key} mods=#{mods.count}}"
  end
  
  def metadataRow
    @metadataRow ||= Metadata.family_rows[key]
  end
  
  class << self 
    attr_reader :all
       
    def familyForKey(key)
      @index[key]
    end
    
    alias [] familyForKey

    def familiesForCategoryKey(categoryKey)
      Metadata.category_models[categoryKey].map { |k| familyForKey(k) }
    end
    
    def familiesForBrandKey(brandKey)
      Metadata.brand_models[brandKey].map { |k| familyForKey(k) }
    end
    
    # Search by: land, land cruiser, toyota, toyota land, toyota land cruiser
    def familiesForText(text, inCollection:collection)
      pattern = /\b#{text.downcase}/i
      collection.select { |m| m.name =~ pattern }
    end

    def keys
      @keys ||= Metadata.family_keys
    end
    
    def load      
      @all = keys.map { |k| new(k) }
      @index = @all.uniqueIndexBy(&:key)
    end    
  end  
  
  class IndexByBrand
    def [](brandKey)
      ModelFamily.familiesForBrandKey(brandKey)
    end
    
    def keys
      Brand.keys
    end
  end
end
