class Parameter
  attr_accessor :key, :name

  def initialize(key, name)
    @key, @name = key, name
  end

  def localizedName
    if Disk.unitSystem != 'SI' && key == 'acceleration_100kmh'
      'Acelleration (0–62 mph)'
    else
      name
    end
  end

  def unitKey
    Metadata.parameterUnits[key]
  end
  
  def defaultUnitKeyInCurrentSystem
    unitSystem = Disk.unitSystem
    
    return unitKey if unitSystem == 'SI'
    
    if dualUnits = Metadata.parameterUnitsOverrides[unitSystem]['dual_fields'][key]
      return dualUnits.first
    end
    
    Metadata.parameterUnitsOverrides[unitSystem]['fields'][key] || 
    Metadata.parameterUnitsOverrides[unitSystem]['units'][unitKey] || unitKey
  end
  
  def unitName
    Metadata.parameterUnitNames[unitKey]
  end
  
  def localizedUnitName
    Metadata.parameterUnitNames[defaultUnitKeyInCurrentSystem]
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

  # def formattedValue(value)
  #   return "" if value == nil
  #   value = "%.1f" % value if Float === value
  #   "#{value} #{unitName}".strip
  # end
  #
  # def formattedValueForMod(mod)
  #   value = mod.get(key)
  #   # value = convertToDisplayUnit(value) if Disk.unitSystem != 'si'
  #   case key
  #   when 'brand_country'
  #     NSLocale.currentLocale.displayNameForKey(NSLocaleCountryCode, value: value)
  #   when 'body', 'drive', 'transmission', 'fuel', 'compressor', 'engine_layout', 'cylinder_placement'
  #     Metadata.parameterTranslations[key][value.to_s]
  #   # when 'produced_since', 'produced_till'
  #   #   year, month = value.to_i.divmod(100)
  #   #   month == 0 ? year : "#{year}.#{month.to_s.rjust(2, '0')}"
  #   else
  #     formattedValue(value)
  #   end
  # end
  
  def inspect
    "{#{key}}"
  end
  
  class << self
    attr_reader :all

    def parameterForKey(key)
      @index[key] || raise("Missing parameter for key #{key}")
    end
    
    alias [] parameterForKey
    
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
  
  CONVERTIONS = {
    nm__lb_ft: 0.7376,
    mm__in: 1 / 25.4,
    kg__lbs: 0.454,
    kmh__mph: 0.621,
    l100km__uk_mpg: 282.48, # 282 / x
    l100km__us_mpg: 235.21,
    cc__in3: 1 / 16.387,
    l__us_gal: 1 / 3.785,
    l__uk_gal: 1 / 4.546,
    l__in3: 61.02,
    l__ft3: 1 / 28.32,
    PS__bhp: 0.986,
    PS__kW: 0.735,
    bhp__kW: 0.745,
  }
end

