class Parameter
  attr_accessor :key, :name

  def initialize(key, name)
    @key, @name = key, name
  end

  def unitKey
    Metadata.parameterUnits[key]
  end
  
  def unitName
    Metadata.parameterUnitNames[unitKey]
  end
  
  def long?
    LongParameters.containsObject(key)
  end

  def appliesToBody?
    BodyParameters.containsObject(key)
  end

  def selected?
    Disk.currentParameters.include?(self)
  end

  def select!
    Disk.currentParameters = Disk.currentParameters.dupWithToggledObject(self)
  end

  def formattedValue(value)
    return "" if value == nil
    value = "%.1f" % value if Float === value
    "#{value} #{unitName}".strip
  end
  
  def formattedValueForMod(mod)
    value = mod.get(key)
    case key
    when 'brand_country'
      NSLocale.currentLocale.displayNameForKey(NSLocaleCountryCode, value: value)
    when 'body', 'drive', 'transmission', 'fuel', 'compressor', 'engine_layout', 'cylinder_placement'
      Metadata.parameterTranslations[key][value.to_s]
    when 'produced_since', 'produced_till'
      year, month = value.to_i.divmod(100)
      month == 0 ? year : "#{year}.#{month.to_s.rjust(2, '0')}"      
    else
      formattedValue(value)
    end
  end 
  
  def inspect
    "{#{key}}"
  end
  
  class << self
    attr_reader :all

    def parameterForKey(key)
      @index[key] || raise("Missing parameter for key #{key}")
    end
    
    def load
      @all = Metadata.parameterNames.map { |key, name| new(key, name) }
      @index = @all.uniqueIndexBy(&:key)
    end
    
    def groupKeys
      Metadata.parameterGroups
    end

    def groupsKeysForCharting
      Metadata.parameterGroupsForCharting
    end
    
        
    
    def nameForGroup(groupKey)
      Metadata[:parameterGroupsData][groupKey][0]
    end
    
    def parametersForGroup(groupKey)
      @parametersGroup ||= {}
      @parametersGroup[groupKey] ||= Metadata.parameterGroupsData[groupKey][1].map { |k| parameterForKey(k) }
    end
    
    def chartableParametersForGroup(groupKey)
      @chartableParametersGroup ||= {}
      @chartableParametersGroup[groupKey] ||= Metadata.parameterGroupsDataForCharting[groupKey][1].map { |k| parameterForKey(k) }
    end
  end
  
  BodyParameters = NSSet.setWithArray([:length, :width, :height])
  LongParameters = NSSet.setWithArray([:consumption_city, :consumption_highway, :consumption_mixed])
end
