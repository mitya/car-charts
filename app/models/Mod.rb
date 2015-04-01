class Mod < DSCoreModel
  NameEngine = 1 << 0
  NameVersion = 1 << 1
  NameBody = 1 << 2
  NameModel = 1 << 3
  NameYear = 1 << 4
  NameShortYear = 1 << 5
  NameBodyVersion = NameBody | NameVersion
  NameBodyVersionYear  = NameBody | NameVersion | NameYear
  NameBodyVersionShortYear  = NameBody | NameVersion | NameShortYear
  NameBodyEngineVersion = NameBody | NameEngine | NameVersion
  NameBodyEngineVersionYear = NameBody | NameEngine | NameVersion | NameYear
  NameBodyEngineVersionShortYear = NameBody | NameEngine | NameVersion | NameShortYear
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
    result = [modelPart, bodyPart, enginePart, versionPart].compact.join(' ')
    result = [year, result].join(', ') if options & NameYear > 0 && year
    result = [shortYear, result].join(', ') if options & NameShortYear > 0 && year    
    result
  end

  ####

  # Opel Astra 2012
  def modelNameWithYear
    model.name
  end

  def bodyName
    Metadata.parameterTranslations['body'][body] || raise("No name for body '#{body}'")
  end

  def versionName
    Metadata['model_versions'][modelKeyWithVersion] if version_key
  end

  def suffix
    if diesel? then 'd'
    elsif compressor? && !diesel? then 'T'
    else ''
    end
  end
  
  def to_s
    "{#{key}}"
  end
  
  def shortYear
    "ʼ" + year.to_s[-2..-1] if year
  end

  alias inspect to_s

  def model
    @model ||= ModelGeneration.generationForKey(generation_key)
  end
  
  def family
    generation.family
  end
  
  alias generation model
  
  def family_key
    model_key
  end

  def category
    family.category
  end

  def modelKeyWithVersion
    version_key ? "#{family_key}.#{version_key}" : family_key
  end
  
  def max_power_range
    max_power_range_end && max_power_range_end > 0 ? "#{max_power_range_start}#{THIN_SPACE}–#{THIN_SPACE}#{max_power_range_end}" : max_power_range_start
  end
  
  def max_torque_range
    max_torque_range_end && max_torque_range_end > 0 ?  "#{max_torque_range_start}#{THIN_SPACE}–#{THIN_SPACE}#{max_torque_range_end}" : max_torque_range_start
  end
  
  def bore_and_stroke
    [bore, stroke].reject { |val| val == nil || val == 0 }.map(&:to_i).join(' × ')
  end
  
  def max_power_string
    "#{max_power}#{THIN_SPACE}hp / #{max_power_kw}#{THIN_SPACE}kW @ #{max_power_range}"
  end
  
  def max_torque_string
    "#{max_torque}#{THIN_SPACE}Hm @ #{max_torque_range}"
  end
  
  # body, assembly countries, brand country, drive, transmission, fuel
  # engine_layout cylinder_placement compressor
  
  def selected?
    Disk.currentMods.include?(self)
  end
  
  def select!
    Disk.toggleModInCurrentList(self)
  end

  
  def gas?
    fuel == 'i'
  end
  
  def diesel?
    fuel == 'd'
  end
  
  def compressor?
    compressor != 0
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
    ['acceleration_100kmh',    NSFloatAttributeType,     false],
    ['assembly_countries',              NSStringAttributeType,    false],
    ['body',                   NSStringAttributeType,    false],
    ['bore',                   NSFloatAttributeType,     false],
    ['brand_country',              NSStringAttributeType,    false],
    ['compression',            NSFloatAttributeType,     false],
    ['compressor',             NSInteger16AttributeType, false],
    ['consumption_city',       NSFloatAttributeType,     false],
    ['consumption_highway',    NSFloatAttributeType,     false],
    ['consumption_mixed',      NSFloatAttributeType,     false],
    ['cylinder_count',         NSInteger32AttributeType, false],
    ['cylinder_placement',     NSStringAttributeType,    false],
    ['cylinder_valves',        NSInteger32AttributeType, false],
    ['displacement',           NSInteger32AttributeType, false],
    ['displacement_key',       NSStringAttributeType,    false],
    ['doors',                  NSInteger32AttributeType, false],
    ['drive',                  NSStringAttributeType,    false],
    ['engine_layout',          NSInteger16AttributeType, false],
    ['front_tire_rut',         NSInteger32AttributeType, false],
    ['fuel',                   NSStringAttributeType,    false],
    ['fuel_rating',            NSStringAttributeType,    false],
    ['gears',                  NSInteger32AttributeType, false],
    ['generation_key',        NSStringAttributeType,    false],
    ['gross_mass',             NSInteger32AttributeType, false],
    ['ground_clearance',       NSInteger32AttributeType, false],
    ['height',                 NSInteger32AttributeType, false],
    ['injection',              NSInteger16AttributeType, false],
    ['kerbweight',             NSInteger32AttributeType, false],
    ['length',                 NSInteger32AttributeType, false],
    ['luggage_max',            NSInteger32AttributeType, false],
    ['luggage_min',            NSInteger32AttributeType, false],
    ['max_power',              NSInteger32AttributeType, false],
    ['max_power_kw',           NSInteger32AttributeType, false],
    ['max_power_range_end',    NSInteger32AttributeType, false],
    ['max_power_range_start',  NSInteger32AttributeType, false],
    ['max_torque',             NSInteger32AttributeType, false],
    ['max_torque_range_end',   NSInteger32AttributeType, false],
    ['max_torque_range_start', NSInteger32AttributeType, false],
    ['model_key',              NSStringAttributeType,    false],
    ['rear_tire_rut',          NSInteger32AttributeType, false],
    ['stroke',                 NSFloatAttributeType,     false],
    ['tank_capacity',          NSInteger32AttributeType, false],
    ['tires',                  NSStringAttributeType,    false],
    ['top_speed',              NSInteger32AttributeType, false],
    ['transmission',           NSStringAttributeType,    false],    
    ['version_key',            NSStringAttributeType,    false],
    ['wheelbase',              NSInteger32AttributeType, false],
    ['width',                  NSInteger32AttributeType, false],
    ['year',                  NSInteger32AttributeType,    false],
    # ['produced_since',         NSInteger32AttributeType, false],
    # ['produced_till',          NSInteger32AttributeType, false],
    # ['seats_max',              NSInteger32AttributeType, false],
    # ['seats_min',              NSInteger32AttributeType, false],
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
    
    def modsForGenerationKey(generationKey)
      context.fetchEntity(entity, predicate:["generation_key = %@", generationKey], order:"key")
    end

    def modsForFamilyKey(familyKey)
      context.fetchEntity(entity, predicate:["model_key = %@", familyKey], order:"key")
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
      KK.benchmark "Import Mods" do
        NSLog "Data path: #{KK.documentsURL}"
        deleteAll
        fields = @fields.map(&:first)
        NSLog "Params delta: #{(Metadata.parameter_keys - fields).join(',')} | #{(fields - Metadata.parameter_keys).join(',')}"
      
        fields.delete 'key'
        plist = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db/mods", ofType:"plist"))
      
        NSLog "Importing #{plist.count} records"
      
        plist.each do |key, data|
          mod = Mod.build(key: key)
          Metadata.parameter_keys.each { |field| mod.set(field, data[fieldIndexInPlist(field)].presence) }
        end      
        
        Mod.save
      end
    end
  
    def fieldIndexInPlist(key)
      @keyIndex || begin
        @keyIndex = {}
        Metadata.parameter_keys.each_with_index { |key, index| @keyIndex[key] ||= index }
      end
      @keyIndex[key] || raise("No index for key '#{key}'")
    end    
  end
end
