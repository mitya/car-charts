class ModelGeneration
  attr_reader :key

  def initialize(key)
    @key = key
  end

  def familyKey
    metadataRow[0]
  end

  def year
    metadataRow[1]
  end
  
  def year_apostrophe
    "ʼ" + year.to_s[-2..-1]
  end

  def unbrandedName
    metadataRow[2]
  end
  
  def nameWithApostrophe
    "#{family.name} #{year_apostrophe}"
  end

  def family
    ModelFamily[familyKey]
  end

  def name
    @name ||= brand.name + ' ' + unbrandedName
  end

  def brandKey
    family.brandKey
  end

  def categoryKey
    family.categoryKey
  end

  def brand
    family.brand
  end

  def category
    family.category
  end

  def selectedModsCount
    Disk.currentMods.select{ |mod| mod.generation == self }.count
  end

  def mods
    Mod.modsForGenerationKey(key)
  end

  def inspect
    "{generation:#{key} mods=#{mods.count}}"
  end
  
  def nameAttributedString
    text = NSMutableAttributedString.alloc.init
    model_name = NSAttributedString.alloc.initWithString family.name + ' ', attributes: { }
    year = NSAttributedString.alloc.initWithString year_apostrophe, attributes: { 
      NSFontAttributeName => UIFont.systemFontOfSize(14), 
      NSForegroundColorAttributeName => UIColor.lightGrayColor }
    text.appendAttributedString(model_name)
    text.appendAttributedString(year)
    text
  end
  
  alias to_s inspect

  def metadataRow
    @metadataRow ||= Metadata.generation_rows[key]
  end

  class << self
    attr_reader :all

    def generationForKey(key)
      @index[key]
    end
    
    alias [] generationForKey

    def generationsForCategoryKey(categoryKey)
      ModelFamily.familiesForCategoryKey(categoryKey).map { |f| f.generations }.flatten
    end

    def generationsForBrandKey(brandKey)
      ModelFamily.familiesForBrandKey(brandKey).map { |f| f.generations }.flatten
    end

    # Search by: land, land cruiser, toyota, toyota land, toyota land cruiser
    def modelsForText(text, inCollection:collection)
      pattern = /\b#{text.downcase}/i
      collection.select { |m| m.name =~ pattern }
    end

    def keys
      @keys ||= Metadata.generation_keys
    end

    def load
      @all = keys.map { |k| new(k) }
      @index = @all.uniqueIndexBy(&:key)
    end
  end

  class IndexByBrand
    def [](brandKey)
      ModelGeneration.generationsForBrandKey(brandKey)
    end

    def keys
      Brand.keys
    end
  end
end
