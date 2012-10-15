class Mod < DSCoreModel
  def model
    @model ||= Model.by(model_key)
  end
  
  def full_name
    "#{model.name} #{nameNoBody}"
  end
  
  def nameNoBody
    "#{engine_vol}#{fuel_suffix}#{compressor_suffix} #{power}ps #{transmission}"
  end
  
  def nameWithVersion
    !version_subkey.blank? ? "#{nameNoBody}, #{version_subkey}" : nameNoBody
  end
  
  def mod_name
    "#{nameNoBody}, #{version}"
  end
  
  def category
    Metadata[:model_info][model_key][3]
  end
  
  def body_name
    Metadata.bodyNames[body] || "!!! #{body}"
  end
  
  def version
    @version ||= [body_name, version_subkey].join(' ')
  end
  
  def fuel_suffix
    fuel == 'i' ? '' : 'd'
  end
  
  def compressor_suffix
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
  
  AutomaticTransmissions = %w(AT AMT CVT)  

  class << self
    def keyRequest
      return @request if @request
      @request = NSFetchRequest.alloc.init
      @request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)
      @request
    end

    def byKeys(keys) 
      keyRequest.predicate = NSPredicate.predicateWithFormat("key in %@", argumentArray:[keys])
      err = Hel.newErr
      unless results = context.executeFetchRequest(keyRequest, error:err)
        raise "Error when fetching data: #{err.value.description}"
      end
      results      
    end
    
    def byModelKey(modelKey)
      keyRequest.predicate = NSPredicate.predicateWithFormat("model_key = %@", argumentArray:[modelKey])
      err = Hel.newErr
      unless results = context.executeFetchRequest(keyRequest, error:err)
        raise "Error when fetching data: #{err.value.description}"
      end
      results
    end
    
    def by(key) 
      # where(key: key).first
            
      keyRequest.predicate = NSPredicate.predicateWithFormat("key = %@", argumentArray:[key])
      err = Hel.newErr
      unless results = context.executeFetchRequest(keyRequest, error:err)
        raise "Error when fetching data: #{err.value.description}"
      end
      results.first
      
    end
  
    def availableFilterOptionsFor(mods)
      options = {}
      mods.each do |mod|
        options[:mt] = true if options[:mt].nil? && mod.manual?
        options[:at] = true if options[:at].nil? && mod.automatic?
        options[:sedan] = true if options[:sedan].nil? && mod.sedan?
        options[:hatch] = true if options[:hatch].nil? && mod.hatch?
        options[:wagon] = true if options[:wagon].nil? && mod.wagon?
        options[:gas] = true if options[:gas].nil? && mod.gas?
        options[:diesel] = true if options[:diesel].nil? && mod.diesel?
      end
      options
    end
  end

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
    
  def self.importFromObjects
    fields = @fields.map { |field, _| field }.reject { |field| field == 'key' }
    Modification.all.each do |m|
      mod = Mod.build
      mod.key = m.key
      fields.each { |field| mod.set(field, m[field].presence) }
    end
    Mod.save
  end
  
  def self.importFromPlist
    fields = @fields.map(&:first).reject { |field| field == 'key' }
    plist = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db-modifications", ofType:"plist"))

    plist.each do |key, data|
      mod = Mod.build
      mod.key = key
      fields.each { |field| mod.set(field, data[Modification.indexForKey(field)].presence) }
    end
    Mod.save
  end
end
