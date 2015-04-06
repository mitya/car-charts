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

  def stringInDefaultUnit
    system = Disk.unitSystem
    formattedValueInUnit(Parameter[field].defaultUnitKeyInCurrentSystem)
  end
  
  def formattedValueInUnit(targetUnit, outputUnits=true)
    result = valueInUnit(targetUnit)
    return "" if result == nil || result == 0
    targetUnitName = Metadata.parameterUnitNames[targetUnit] if outputUnits
    
    if result.is_a?(Integer) || integer_field?(field)
      result = formatInteger(result)
    elsif result.is_a?(Float) 
      result = formatFloat(result)
    end
    
    if outputUnits
      "#{result} #{targetUnitName}".strip
    else
      result
    end
  end

  def valueInUnit(targetUnit)
    return nil if value == nil
    return nil if value == 0
    return value if unit == targetUnit

    ratio = Parameter::CONVERTIONS["#{unit}__#{targetUnit}".to_sym]
    result = if unit == 'l100km'
      ratio / value
    else
      value * ratio
    end
    
    result = result.round if integer_field?(field)
    result
  end
  
  def unitInSystem(system = 'SI', field = 'none')
    return unit if system == 'SI'
    Metadata.parameterUnitsOverrides[system]['fields'][field] || Metadata.parameterUnitsOverrides[system]['units'][unit] || unit
  end
  
  def formatInteger(integer)    
    NUMBER_FORMATTER.stringFromNumber NSNumber.numberWithInteger(integer)
  end  
  
  # ParameterValue::NUMBER_FORMATTER.stringFromNumber NSNumber.numberWithDouble(10000.456789)
  def formatFloat(float)
    NUMBER_FORMATTER.stringFromNumber NSNumber.numberWithDouble(float)
  end

  STRING_FIELDS = NSSet.setWithArray %w(body drive transmission fuel compressor engine_layout cylinder_placement)
  CONSUMPTION_FIELDS = NSSet.setWithArray %w(consumption_city consumption_highway consumption_mixed)
  INTEGER_FIELDS = NSSet.setWithArray %w(top_speed max_torque gross_mass kerbweight)

  def integer_field?(field)
    (CONSUMPTION_FIELDS.containsObject(field) && Disk.unitSystem != 'SI') || INTEGER_FIELDS.containsObject(field)
  end
  
  NUMBER_FORMATTER = begin
    formatter = NSNumberFormatter.alloc.init
    formatter.usesGroupingSeparator = YES
    formatter.maximumFractionDigits = 1
    formatter
  end
  
  def self.DUAL_FIELDS
    @dual_fields ||= {}
    @dual_fields[Disk.unitSystem] ||= NSSet.setWithArray Metadata.parameterUnitsOverrides[Disk.unitSystem]['dual_fields'].keys
  end
end
