class Mod < DSCoreModel
  def model
    @model ||= Model.modelForKey(model_key)
  end
  
  def fullName
    "#{model.name} #{basicName}"
  end
  
  def basicName
    "#{engine_vol}#{fuelSuffix}#{compressorSuffix} #{power}ps #{transmission}"
  end
  
  def nameWithVersion
    !version_subkey.blank? ? "#{basicName}, #{version_subkey}" : basicName
  end
  
  def modName
    "#{basicName}, #{version}"
  end
  
  def category
    Metadata[:model_info][model_key][3]
  end
  
  def bodyName
    Metadata.bodyNames[body] || "!!! #{body}"
  end
  
  def version
    @version ||= [bodyName, version_subkey].join(' ')
  end
  
  def fuelSuffix
    fuel == 'i' ? '' : 'd'
  end
  
  def compressorSuffix
    compressor && fuel != 'd' ? "T" : ""
  end
  
  def gas?
    fuel == 'i'
  end
  
  def diesel?
    fuel == 'd'
  end
  
  def automatic?
    AutomaticTransmissions.include?(transmission)
  end

  def manual?
    transmission == "MT"
  end

  def sedan?
    body == 'sedan'
  end

  def wagon?
    body == 'wagon'
  end
  
  def hatch?
    body.start_with?('hatch')
  end
  
  def [](key)
    key = key.key if Parameter === key
    get(key)
  end
  
  def fieldTextFor(parameter)
    value = get(parameter.key)
    valueText = Float === value ? "%.1f" % value : value.to_s
    "#{valueText} #{parameter.unitName}"
  end
  
  AutomaticTransmissions = %w(AT AMT CVT)  

  @contextName = :staticContext
  @defaultSortField = 'key'
  @fields = [
    ['key', NSStringAttributeType, true],
    ['acceleration_0_100_kmh', NSFloatAttributeType, false],
    ['base_model_key', NSStringAttributeType, false],
    ['body', NSStringAttributeType, false],
    ['body_title', NSStringAttributeType, false],
    ['body_type', NSStringAttributeType, false],
    ['bore', NSFloatAttributeType, false],
    ['car_class', NSStringAttributeType, false],
    ['compression', NSFloatAttributeType, false],
    ['compressor', NSStringAttributeType, false],
    ['consumption_city', NSFloatAttributeType, false],
    ['consumption_highway', NSFloatAttributeType, false],
    ['consumption_mixed', NSFloatAttributeType, false],
    ['countries', NSStringAttributeType, false],
    ['cylinder_count', NSInteger32AttributeType, false],
    ['cylinder_placement', NSStringAttributeType, false],
    ['doors', NSStringAttributeType, false], # int
    ['drive', NSStringAttributeType, false],
    ['drive_config', NSStringAttributeType, false],
    ['engine_placement', NSStringAttributeType, false],
    ['engine_spec', NSStringAttributeType, false],
    ['engine_title', NSStringAttributeType, false],
    ['engine_vol', NSStringAttributeType, false], # int
    ['engine_volume', NSInteger32AttributeType, false],
    ['fixed_model_name', NSStringAttributeType, false],
    ['front_brakes', NSStringAttributeType, false],
    ['front_suspension', NSStringAttributeType, false],
    ['front_tire_rut', NSInteger32AttributeType, false],
    ['fuel', NSStringAttributeType, false],
    ['fuel_rating', NSStringAttributeType, false],
    ['gears', NSInteger32AttributeType, false],
    ['gross_mass', NSInteger32AttributeType, false],
    ['ground_clearance', NSInteger32AttributeType, false],
    ['height', NSInteger32AttributeType, false],
    ['injection', NSStringAttributeType, false],
    ['kerbweight', NSInteger32AttributeType, false],
    ['length', NSInteger32AttributeType, false],
    ['luggage_max', NSInteger32AttributeType, false],
    ['luggage_min', NSInteger32AttributeType, false],
    ['max_power', NSInteger32AttributeType, false],
    ['max_power_kw', NSInteger32AttributeType, false],
    ['max_power_range_end', NSInteger32AttributeType, false],
    ['max_power_range_start', NSInteger32AttributeType, false],
    ['max_torque', NSInteger32AttributeType, false],
    ['max_torque_range_end', NSInteger32AttributeType, false],
    ['max_torque_range_start', NSInteger32AttributeType, false],
    ['model_key', NSStringAttributeType, false],
    ['model_title', NSStringAttributeType, false],
    ['power', NSInteger32AttributeType, false],
    ['price', NSStringAttributeType, false],
    ['produced_since', NSStringAttributeType, false],
    ['produced_till', NSStringAttributeType, false],
    ['rear_brakes', NSStringAttributeType, false],
    ['rear_suspension', NSStringAttributeType, false],
    ['rear_tire_rut', NSInteger32AttributeType, false],
    ['seats', NSStringAttributeType, false], # int
    ['stroke', NSFloatAttributeType, false],
    ['tank_capacity', NSInteger32AttributeType, false],
    ['tires', NSStringAttributeType, false],
    ['top_speed', NSInteger32AttributeType, false],
    ['transmission', NSStringAttributeType, false],
    ['valves_per_cylinder', NSInteger32AttributeType, false],
    ['version', NSStringAttributeType, false],
    ['version_subkey', NSStringAttributeType, false],
    ['wheelbase', NSInteger32AttributeType, false],
    ['width', NSInteger32AttributeType, false],
  ]

  Keys = %w(body version_subkey transmission drive engine_vol fuel power model_key
    valves_per_cylinder consumption_city max_power_kw cylinder_placement compression gross_mass bore doors compressor
    injection tires max_torque_range_start rear_brakes max_torque max_power stroke seats acceleration_0_100_kmh consumption_highway
    engine_spec consumption_mixed countries fuel_rating height drive_config produced_since rear_tire_rut engine_title luggage_min
    length engine_volume body_type max_power_range_start kerbweight car_class ground_clearance luggage_max front_suspension
    price tank_capacity wheelbase model_title front_brakes engine_placement rear_suspension top_speed gears width front_tire_rut
    cylinder_count body_title produced_till max_torque_range_end max_power_range_end version base_model_key fixed_model_name)

  class << self
    def modForKey(key)
      context.fetchEntity(entity, predicate:["key = %@", key]).first
    end

    def modsForKeys(keys) 
      context.fetchEntity(entity, predicate:["key in %@", keys])
    end
    
    def modsForModelKey(modelKey)
      context.fetchEntity(entity, predicate:["model_key = %@", modelKey])
    end

    def filterOptionsForMods(mods)
      mods.reduce({}) do |options, mod|
        options[:mt] = true if options[:mt].nil? && mod.manual?
        options[:at] = true if options[:at].nil? && mod.automatic?
        options[:sedan] = true if options[:sedan].nil? && mod.sedan?
        options[:hatch] = true if options[:hatch].nil? && mod.hatch?
        options[:wagon] = true if options[:wagon].nil? && mod.wagon?
        options[:gas] = true if options[:gas].nil? && mod.gas?
        options[:diesel] = true if options[:diesel].nil? && mod.diesel?
        
        options[:transmission] = [options[:mt], options[:at]].compact
        options[:body] = [options[:sedan], options[:wagon], options[:hatch]].compact
        options[:fuel] = [options[:gas], options[:diesel]].compact
        
        options
      end
    end
  
    def importFromPlist
      fields = @fields.map(&:first).reject { |field| field == 'key' }
      plist = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db-modifications", ofType:"plist"))

      plist.each do |key, data|
        mod = Mod.build(key: key)
        fields.each { |field| mod.set(field, data[indexForKey(field)].presence) }
      end
      Mod.save
    end
  
    def indexForKey(key)
      @keyIndex || begin
        @keyIndex = {}
        Keys.each_with_index { |key, index| @keyIndex[key] ||= index }
      end
      @keyIndex[key]
    end    
  end
end
