class ParameterValue
  attr :unit, :value, :field
  
  def initialize(value, unit, field = nil)
    @value = value
    @unit = unit
    @field = field
  end
  
  def format(system = 'SI')
    if value == nil || value == 0
      ''
    elsif self.class.stringFields.containsObject(field)
      Metadata.parameterTranslations[field][value.to_s]  
    elsif field == 'brand_country'
      NSLocale.currentLocale.displayNameForKey(NSLocaleCountryCode, value: value)
    elsif self.class.dualFields.containsObject(field)
      units = Metadata.parameterUnitsOverrides[Disk.parameterUnits]['dual_fields'][field]
      "#{formatWithUnit(units.first)} (#{formatWithUnit(units.last)})"
    else      
      targetUnit = unitInSystem(system, field)
      formatWithUnit(targetUnit)
    end
  end
  
  def formatWithUnit(targetUnit)
    result = valueInUnit(targetUnit)    
    targetUnitName = Metadata.parameterUnitNames[targetUnit]
    if result.is_a?(Float)
      if self.class.integerFields.containsObject(field)
        result = result.round.to_s
      else
        result = "%.1f" % result 
      end
    end
    "#{result} #{targetUnitName}".strip
  end

  def valueInUnit(targetUnit)
    return value if unit == targetUnit
    ratio = Parameter::CONVERTIONS["#{unit}__#{targetUnit}".to_sym]
    if unit == 'l100km'
      ratio / value
    else
      value * ratio
    end
  end
  
  def unitInSystem(system = 'SI', field = 'none')
    return unit if system == 'SI'
    Metadata.parameterUnitsOverrides[system]['fields'][field] || Metadata.parameterUnitsOverrides[system]['units'][unit] || unit
  end

  def self.stringFields
    @@string_fields ||= NSSet.setWithArray %w(body drive transmission fuel compressor engine_layout cylinder_placement)
  end  
  
  def self.integerFields
    @@integer_fields ||= NSSet.setWithArray %w(top_speed consumption_city consumption_highway consumption_mixed gross_mass kerbweight)    
  end
  
  def self.dualFields
    @@integer_fields ||= NSSet.setWithArray Metadata.parameterUnitsOverrides[Disk.parameterUnits]['dual_fields'].keys
  end
end
