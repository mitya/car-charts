class Modification
  @fields = [
    ['body',                   NSStringAttributeType, false],
    ['version_subkey',         NSStringAttributeType, false],
    ['transmission',           NSStringAttributeType, false],
    ['drive',                  NSStringAttributeType, false],
    ['engine_vol',             NSStringAttributeType, false],
    ['fuel',                   NSStringAttributeType, false],
    ['power',                  NSStringAttributeType, false],
    ['model_key',              NSStringAttributeType, false],
    ['valves_per_cylinder',    NSStringAttributeType, false],
    ['consumption_city',       NSStringAttributeType, false],
    ['max_power_kw',           NSStringAttributeType, false],
    ['cylinder_placement',     NSStringAttributeType, false],
    ['compression',            NSStringAttributeType, false],
    ['gross_mass',             NSStringAttributeType, false],
    ['bore',                   NSStringAttributeType, false],
    ['doors',                  NSStringAttributeType, false],
    ['compressor',             NSStringAttributeType, false],
    ['injection',              NSStringAttributeType, false],
    ['tires',                  NSStringAttributeType, false],
    ['max_torque_range_start', NSStringAttributeType, false],
    ['rear_brakes',            NSStringAttributeType, false],
    ['max_torque',             NSStringAttributeType, false],
    ['max_power',              NSStringAttributeType, false],
    ['stroke',                 NSStringAttributeType, false],
    ['seats',                  NSStringAttributeType, false],
    ['acceleration_0_100_kmh', NSStringAttributeType, false],
    ['consumption_highway',    NSStringAttributeType, false],
    ['engine_spec',            NSStringAttributeType, false],
    ['consumption_mixed',      NSStringAttributeType, false],
    ['countries',              NSStringAttributeType, false],
    ['fuel_rating',            NSStringAttributeType, false],
    ['height',                 NSStringAttributeType, false],
    ['drive_config',           NSStringAttributeType, false],
    ['produced_since',         NSStringAttributeType, false],
    ['rear_tire_rut',          NSStringAttributeType, false],
    ['engine_title',           NSStringAttributeType, false],
    ['luggage_min',            NSStringAttributeType, false],
    ['length',                 NSStringAttributeType, false],
    ['engine_volume',          NSStringAttributeType, false],
    ['body_type',              NSStringAttributeType, false],
    ['max_power_range_start',  NSStringAttributeType, false],
    ['kerbweight',             NSStringAttributeType, false],
    ['fuel',                   NSStringAttributeType, false],
    ['car_class',              NSStringAttributeType, false],
    ['ground_clearance',       NSStringAttributeType, false],
    ['luggage_max',            NSStringAttributeType, false],
    ['front_suspension',       NSStringAttributeType, false],
    ['price',                  NSStringAttributeType, false],
    ['tank_capacity',          NSStringAttributeType, false],
    ['wheelbase',              NSStringAttributeType, false],
    ['model_title',            NSStringAttributeType, false],
    ['front_brakes',           NSStringAttributeType, false],
    ['engine_placement',       NSStringAttributeType, false],
    ['rear_suspension',        NSStringAttributeType, false],
    ['top_speed',              NSStringAttributeType, false],
    ['gears',                  NSStringAttributeType, false],
    ['width',                  NSStringAttributeType, false],
    ['front_tire_rut',         NSStringAttributeType, false],
    ['cylinder_count',         NSStringAttributeType, false],
    ['transmission',           NSStringAttributeType, false],
    ['body_title',             NSStringAttributeType, false],
    ['produced_till',          NSStringAttributeType, false],
    ['max_torque_range_end',   NSStringAttributeType, false],
    ['max_power_range_end',    NSStringAttributeType, false],
    ['version',                NSStringAttributeType, false],
    ['base_model_key',         NSStringAttributeType, false],
    ['fixed_model_name',       NSStringAttributeType, false],
  ]

  attr_accessor :data, :key
  attr_accessor :model, :body, :engine_vol, :fuel, :power, :transmission, :drive, :version_subkey
  
  def initialize(key, data)
    @key, @data = key, data
    @model = Model.by(self['model_key'])
  end
  
  def body() self['body'] end
  def engine_vol() self['engine_vol'] end
  def fuel() self['fuel'] end
  def power() self['power'] end
  def transmission() self['transmission'] end
  def drive() self['drive'] end
  def version_subkey() self['version_subkey'] end
  def model_key() self['model_key'] end
  
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
    Metadata.model_classes[model.key]
  end
  
  def body_name
    Metadata.bodyNames[body] || "!!! #{body}"
  end
  
  def version
    @version ||= [body_name, version_subkey].join(' ')
  end
  
  def version_name
    self['version_name']
  end
  
  def fuel_suffix
    fuel == 'i' ? '' : 'd'
  end
  
  def compressor_suffix
    self['compressor'] && fuel != 'd' ? "T" : ""
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
    index = self.class.indexForKey(key.to_s)
    data[index]
  end
  
  AutomaticTransmissions = %w(AT AMT CVT)  

  class << self
    attr_reader :all
    
    def by(key) 
      @index[key] 
    end
  
    def load
      plist = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db-modifications", ofType:"plist"))
      
      @all = plist.map { |key, data| new(key, data) }

      @index = {}
      @all.each do |mod|
        @index[mod.key] = mod
        mod.model.modifications << mod
      end
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

    def indexForKey(key)
      @keyIndex || begin
        @keyIndex = {}
        Keys.each_with_index { |key, index| @keyIndex[key] ||= index }
      end
      @keyIndex[key]
    end    
  end
  
  Keys = %w(body version_subkey transmission drive engine_vol fuel power model_key
    valves_per_cylinder consumption_city max_power_kw cylinder_placement compression gross_mass bore doors compressor
    injection tires max_torque_range_start rear_brakes max_torque max_power stroke seats acceleration_0_100_kmh consumption_highway
    engine_spec consumption_mixed countries fuel_rating height drive_config produced_since rear_tire_rut engine_title luggage_min
    length engine_volume body_type max_power_range_start kerbweight fuel car_class ground_clearance luggage_max front_suspension
    price tank_capacity wheelbase model_title front_brakes engine_placement rear_suspension top_speed gears width front_tire_rut
    cylinder_count transmission body_title produced_till max_torque_range_end max_power_range_end version base_model_key fixed_model_name)

  # Keys = %w(body version_subkey transmission drive engine_vol fuel power model_key compressor drive_config body_type fuel car_class version base_model_key
  #  top_speed acceleration_0_100_kmh consumption_city consumption_highway consumption_mixed engine_volume cylinder_count valves_per_cylinder compression bore
  #  max_power max_power_kw max_torque gears length width height ground_clearance tires front_tire_rut rear_tire_rut wheelbase luggage_min luggage_max
  #  tank_capacity gross_mass kerbweight doors seats produced_since price)
end
