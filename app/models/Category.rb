class Category
  attr_reader :key
  
  def initialize(key)
    @key = key
  end
  
  def name
    @name ||= Metadata.categoryNames[key].first
  end
  
  def shortName
    @shortName ||= Metadata.categoryNames[key].last
  end
  
  def inspect
    "#<Category:#{key} models=#{models.count}>"
  end
  
  def models
    @models ||= ModelGeneration.generationsForCategoryKey(key)
  end
  
  def selectedModsCount
    Disk.currentMods.select { |mod| mod.category == key }.count
  end
  
  class << self 
    attr_reader :index, :all
       
    def [](key)
      @index[key]
    end

    def keys
      @keys ||= Metadata.categoryNames.keys
    end
    
    def load
      @all = keys.map { |key| new(key) }
      @index = @all.uniqueIndexBy(&:key)
    end
    
    def allSortedByName
      @allByName ||= @all.sort_by(&:shortName)
    end
  end  
end
