class ParameterValue
  attr :unit, :value, :field
  
  def initialize(value, unit, field = nil)
    @value = value
    @unit = unit
    @field = field
  end
  
  def string(system = 'SI', units = true)
    if value == nil || value == 0
      ''
    elsif STRING_FIELDS.containsObject(field)
      Metadata.parameterTranslations[field][value.to_s]  
    elsif field == 'brand_country'
      NSLocale.currentLocale.displayNameForKey(NSLocaleCountryCode, value: value)
    elsif ParameterValue.DUAL_FIELDS.containsObject(field)
      units = Metadata.parameterUnitsOverrides[Disk.unitSystem]['dual_fields'][field]
      "#{formattedValueInUnit(units.first)} (#{formattedValueInUnit(units.last)})"
    else      
      targetUnit = unitInSystem(system, field)
      formattedValueInUnit(targetUnit, units)
    end
  end
  
  def formattedValueInUnit(targetUnit, outputUnits=true)
    result = valueInUnit(targetUnit)    
    targetUnitName = Metadata.parameterUnitNames[targetUnit] if outputUnits
    
    if result.is_a?(Float)
      if integer_field?(field)
        result = result.round.to_s
      else
        result = "%.1f" % result 
      end
    end
    
    if outputUnits
      "#{result} #{targetUnitName}".strip
    else
      result
    end
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
  CONSUMPTION_FIELDS = NSSet.setWithArray %w(consumption_city consumption_highway consumption_mixed)
  INTEGER_FIELDS = NSSet.setWithArray %w(top_speed max_torque gross_mass kerbweight)

  def integer_field?(field)
    if CONSUMPTION_FIELDS.containsObject(field) && Disk.unitSystem != 'SI'
      true
    else
      INTEGER_FIELDS.containsObject(field)
    end
  end
  
  def self.DUAL_FIELDS
    @dual_fields ||= {}
    @dual_fields[Disk.unitSystem] ||= begin
      # overrides = Metadata.parameterUnitsOverrides[Disk.unitSystem]
      NSSet.setWithArray Metadata.parameterUnitsOverrides[Disk.unitSystem]['dual_fields'].keys
    end
  end
end
