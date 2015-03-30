class Mod < DSCoreModel
  NameEngine  = 1 << 0
  NameVersion = 1 << 1
  NameBody    = 1 << 2
  NameModel   = 1 << 3
  NameBodyVersion = NameBody | NameVersion
  NameBodyEngineVersion = NameBody | NameEngine | NameVersion
  NameEngineVersion = NameEngine | NameVersion

  # NameEngine: 2.1T 240hp AT
  # NameEngine | NameVersion: 2.1T 240hp AT, OPC
  # NameEngine | NameVersion | NameBody: sedan 2.1T 240hp AT, OPC
  # NameEngine | NameModel | NameVersion: Opel Astra 2.1T 240hp AT, OPC
  # NameEngine | NameModel | NameVersion | NameBody | Opel Astra sedan 2.1T 240hp AT, OPC
  def modName(options = NameEngineVersion)
    enginePart = "#{displacement_key}#{suffix} #{max_power}hp #{transmission}" if options & NameEngine > 0
    bodyPart = bodyName if options & NameBody > 0
    versionPart = versionName if options & NameVersion > 0
    modelPart = model.name if options & NameModel > 0
    [modelPart, bodyPart, enginePart, versionPart].compact.join(' ')
  end

  ####

  # Opel Astra 2012
  def modelNameWithYear
    "#{model.name} #{year}"
  end

  def bodyName
    Metadata.bodyNames[body] || raise("No name for body '#{body}'")
  end

  def versionName
    Metadata['model_versions'][modelKeyWithVersion] if version_key
  end

  def suffix
    if fuel == 'D' then 'd'
    elsif compressor != 0 && fuel != 'D' then 'T'
    else ''
    end
  end
  
  def inspect
    to_s
  end
  
  def to_s
    "{#{key}}"
  end


  def model
    @model ||= Model.modelForKey(model_key)
  end

  def category
    Metadata[:model_info][model_key][3]
  end

  def modelKeyWithVersion
    version_key ? "#{model_key}.#{version_key}" : model_key
  end
  
  def year
    @year ||= produced_since / 100 if produced_since
  end

  
  def selected?
    Disk.currentMods.include?(self)
  end
  
  def select!
    Disk.toggleModInCurrentList(self)
  end

  
  def gas?
    fuel == 'P'
  end
  
  def diesel?
    fuel == 'D'
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

  
  AutomaticTransmissions = %w(AT AMT CVT)  

  @contextName = :staticContext
  @defaultSortField = 'key'
  @fields = [
    ['key',                    NSStringAttributeType,    true ],
    ['body',                   NSStringAttributeType,    false],
    ['model_key',              NSStringAttributeType,    false],
    ['version_key',            NSStringAttributeType,    false],
                               
    ['top_speed',              NSInteger32AttributeType, false],
    ['acceleration_100kmh',    NSFloatAttributeType,     false],
    ['transmission',           NSStringAttributeType,    false],    
    ['drive',                  NSStringAttributeType,    false],
    ['fuel',                   NSStringAttributeType,    false],
    ['fuel_rating',            NSStringAttributeType,    false],
    ['gears',                  NSInteger32AttributeType, false],

    ['displacement_key',       NSStringAttributeType,    false],
    ['displacement',           NSInteger32AttributeType, false],
    ['max_power',              NSInteger32AttributeType, false],
    ['max_power_kw',           NSInteger32AttributeType, false],
    ['max_power_range_start',  NSInteger32AttributeType, false],
    ['max_power_range_end',    NSInteger32AttributeType, false],
    ['max_torque',             NSInteger32AttributeType, false],
    ['max_torque_range_start', NSInteger32AttributeType, false],
    ['max_torque_range_end',   NSInteger32AttributeType, false],
    ['engine_layout',          NSInteger16AttributeType, false],
    ['bore',                   NSFloatAttributeType,     false],
    ['stroke',                 NSFloatAttributeType,     false],
    ['compression',            NSFloatAttributeType,     false],
    ['compressor',             NSInteger16AttributeType, false],
    # ['injection',              NSInteger16AttributeType, false],
    ['consumption_city',       NSFloatAttributeType,     false],
    ['consumption_highway',    NSFloatAttributeType,     false],
    ['consumption_mixed',      NSFloatAttributeType,     false],
    ['cylinder_count',         NSInteger32AttributeType, false],
    ['cylinder_placement',     NSStringAttributeType,    false],
    ['cylinder_valves',        NSInteger32AttributeType, false],

    ['assembly_countries',              NSStringAttributeType,    false],
    # ['produced_since',         NSInteger32AttributeType, false],
    # ['produced_till',          NSInteger32AttributeType, false],
                              
    ['doors',                  NSInteger32AttributeType, false],
    # ['seats_min',              NSInteger32AttributeType, false],
    # ['seats_max',              NSInteger32AttributeType, false],
    ['luggage_max',            NSInteger32AttributeType, false],
    ['luggage_min',            NSInteger32AttributeType, false],
                              
    ['gross_mass',             NSInteger32AttributeType, false],
    ['kerbweight',             NSInteger32AttributeType, false],
    ['height',                 NSInteger32AttributeType, false],
    ['length',                 NSInteger32AttributeType, false],
    ['width',                  NSInteger32AttributeType, false],
    ['wheelbase',              NSInteger32AttributeType, false],
    ['ground_clearance',       NSInteger32AttributeType, false],
    ['front_tire_rut',         NSInteger32AttributeType, false],
    ['rear_tire_rut',          NSInteger32AttributeType, false],
    ['tank_capacity',          NSInteger32AttributeType, false],
    ['tires',                  NSStringAttributeType,    false],
  ]

  
  class << self
    def modForKey(key)
      context.fetchEntity(entity, predicate:["key = %@", key]).first
    end

    def modsForKeys(keys) 
      mods = context.fetchEntity(entity, predicate:["key in %@", keys])
      keys.map { |key| mods.detect { |mod| mod.key == key } }.compact
    end
    
    def unorderedModsForKeys(keys) 
      context.fetchEntity(entity, predicate:["key in %@", keys]).sort_by(&:key)    
    end
    
    def modsForModelKey(modelKey)
      context.fetchEntity(entity, predicate:["model_key = %@", modelKey], order:"key")
    end

    def filterOptionsForMods(mods)
      options = mods.reduce({}) do |options, mod|
        options[:mt] = true if options[:mt].nil? && mod.manual?
        options[:at] = true if options[:at].nil? && mod.automatic?
        options[:sedan] = true if options[:sedan].nil? && mod.sedan?
        options[:hatch] = true if options[:hatch].nil? && mod.hatch?
        options[:wagon] = true if options[:wagon].nil? && mod.wagon?
        options[:gas] = true if options[:gas].nil? && mod.gas?
        options[:diesel] = true if options[:diesel].nil? && mod.diesel?        
        options
      end
      options[:transmission] = [options[:mt], options[:at]].compact
      options[:body] = [options[:sedan], options[:wagon], options[:hatch]].compact
      options[:fuel] = [options[:gas], options[:diesel]].compact
      options
    end
  
  
    # To import a plist:
    # 1. uncomment some stuff in AppDelegate.staticContext
    # 2. find where the app document directory is & remove the old mods.sqlite (KK.documentsURL)
    # 3. run Mod.import in console
    # 4. move the sqlite database from documents dir to the app bundle
    # 5. comment out the shit again
    def import
      NSLog "Importing mods"
      NSLog "Look for data in #{KK.documentsURL}"      
      deleteAll
      fields = @fields.map(&:first)
      NSLog "Param delta: #{Metadata.parameters - fields} / #{fields - Metadata.parameters}"
      
      fields.delete 'key'
      plist = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db/mods", ofType:"plist"))
      
      NSLog "Importing #{plist.count} records"
      
      plist.each do |key, data|
        mod = Mod.build(key: key)
        Metadata.parameters.each { |field| mod.set(field, data[fieldIndexInPlist(field)].presence) }
      end
      
      Mod.save
    end
  
    def fieldIndexInPlist(key)
      @keyIndex || begin
        @keyIndex = {}
        Metadata.parameters.each_with_index { |key, index| @keyIndex[key] ||= index }
      end
      @keyIndex[key] || raise("No index for key '#{key}'")
    end    
  end
end
