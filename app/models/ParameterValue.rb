class ParameterValue
  attr :unit, :value, :field
  
  def initialize(value, unit, field = nil)
    @value = value
    @unit = unit
    @field = field
  end
  
  def string(system = 'SI')
    if value == nil || value == 0
      ''
    elsif STRING_FIELDS.containsObject(field)
      Metadata.parameterTranslations[field][value.to_s]  
    elsif field == 'brand_country'
      NSLocale.currentLocale.displayNameForKey(NSLocaleCountryCode, value: value)
    elsif ParameterValue.DUAL_FIELDS.containsObject(field)
      units = Metadata.parameterUnitsOverrides[Disk.parameterUnits]['dual_fields'][field]
      "#{stringWithUnit(units.first)} (#{stringWithUnit(units.last)})"
    else      
      targetUnit = unitInSystem(system, field)
      stringWithUnit(targetUnit)
    end
  end
  
  def stringWithUnit(targetUnit)
    result = valueInUnit(targetUnit)    
    targetUnitName = Metadata.parameterUnitNames[targetUnit]
    if result.is_a?(Float)
      if INTEGER_FIELDS.containsObject(field)
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

  STRING_FIELDS = NSSet.setWithArray %w(body drive transmission fuel compressor engine_layout cylinder_placement)
  INTEGER_FIELDS = NSSet.setWithArray %w(top_speed max_torque consumption_city consumption_highway consumption_mixed gross_mass kerbweight)
  
  def self.DUAL_FIELDS
    @dual_fields ||= NSSet.setWithArray Metadata.parameterUnitsOverrides[Disk.parameterUnits]['dual_fields'].keys
  end
end
