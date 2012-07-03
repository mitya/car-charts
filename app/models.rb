class Modification
  attr_accessor :data, :key
  attr_accessor :brand_key, :model_key, :body, :engine_vol, :fuel, :power, :transmission, :drive
  
  def initialize(key, data)
    @key = key
    @data = data
    parse_key
  end
  
  def branded_model_name
    @branded_model_name ||= begin
      brand_name = Model.brand_names[@brand_key]
      model_name = Model.model_names[@model_key]
      "#{brand_name} #{model_name}"
    end
  end
  
  def full_name
    "#{branded_model_name} #{engine_vol}#{fuel_suffix} #{transmission}"
  end
  
  def mod_name
    "#{engine_vol}#{fuel_suffix}#{compressor_suffix} #{transmission}, #{body_name}"
  end
  
  def body_name
    Model.body_names[body] || "XXX #{body}"
  end
  
  def version_name
    data['version_name']
  end
  
  def fuel_suffix
    # fuel == 'i' ? '' : ' diesel'
    fuel == 'i' ? '' : 'd'
  end
  
  def compressor_suffix
    # data['compressor'] && fuel != 'd' ? " turbo" : ""
    data['compressor'] && fuel != 'd' ? "T" : ""
  end
  
  def premium?
    Model.premium_brands.containsObject(brand_key)
  end
  
  AutomaticTransmissions = %w(AT AMT CVT)
  def automatic?
    AutomaticTransmissions.include?(@transmission)
  end
  
  def hatch?
    body.start_with?('hatch')
  end
  
  def [](key)
    data[key]
  end
  
  private
  
  # alfa_romeo--159--2005--sedan---1.8i-140ps-MT-FWD
  # [alfa_romeo, 159, 2005, sedan, 1.8, i, 140, MT, FWD]
  # [alfa_romeo--159]
  def parse_key
    @brand_key, model_version, years, @body, agregate = key.split(' ')
    model_subkey, @version_subkey = model_version.split('.')
    @model_key = [@brand_key, model_subkey].join('--')
    
    engine, power, @transmission, @drive = agregate.split('-')
    @engine_vol = engine[0..-2]
    @fuel = engine[-1]
    @power = power.to_i
  end
end

class ModelManager
  attr_accessor :modifications, :modifications_by_mod_key, :modifications_by_model_key, :metadata

  def brand_names
    @metadata['brand_names']
  end
  
  def premium_brands
    @premium_brands ||= NSSet.setWithArray(@metadata['premium_brands'])
  end

  def model_names
    @metadata['model_names']
  end

  def body_names
    @metadata['body_names']
  end
  
  def modification_for(key)
    @modifications_by_mod_key[key]
  end

  def unit_name_for(param)
    unit = ParameterUnits[param.to_sym]
    ParameterUnitNames[unit]
  end
  
  def parameters
    @parameters ||= ParameterNames.map { |key, name| Parameter.new(key, name) }
  end
  
  def current_parameters
    NSUserDefaults.standardUserDefaults["parameters"] || []
  end
  
  def current_parameters=(array)
    NSUserDefaults.standardUserDefaults["parameters"] = array
  end
  
  def load
    modifications_hash = NSMutableDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("modifications", ofType:"plist"))

    @modifications = modifications_hash.map { |key, data| Modification.new(key, data) }
        
    @metadata = NSMutableDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("metadata", ofType:"plist"))

    @modifications_by_mod_key = {}
    @modifications_by_model_key = {}
    @modifications.each do |mod|
      @modifications_by_mod_key[mod.key] = mod
      @modifications_by_model_key[mod.model_key] ||= []
      @modifications_by_model_key[mod.model_key] << mod
    end    
  end
  
  def self.instance
    @instance
  end
  
  def self.load
    @instance.load
  end
  
  @instance = new
end

Model = ModelManager.instance

class Parameter
  attr_accessor :key, :name

  def initialize(key, name)
    @key, @name = key, name
  end

  def unit
    ParameterUnits[key]
  end
  
  def unit_name
    ParameterUnitNames[unit]
  end
end

class Comparision
  attr_accessor :mods, :params
  
  def initialize(mods, params)
    @mods = mods
    @params = params
  end
  
  def values_for(param)
    @values ||= {}
    @values[param] ||= mods.map { |mod| mod[param] }.compact
  end
  
  def max_value_for(param)
    @max_values ||= {}
    @max_values[param] ||= values_for(param).max
  end

  def min_value_for(param)
    @min_values ||= {}
    @min_values[param] ||= values_for(param).min
    # 0
  end
  
  def range_for(param)
    @ranges ||= {}
    @ranges[param] ||= max_value_for(param) - min_value_for(param)    
  end
  
  def items
    @items ||= (0...mods.count).map { |index| ComparisionItem.new(self, index) }
  end
  
  def title
    params.map { |p| ParameterNames[p.to_sym] }.join(' - ')
  end
end

class ComparisionItem
  attr_accessor :index, :comparision
  
  def initialize(comparision, index)
    @comparision, @index = comparision, index
  end
  
  def mods
    @comparision.mods
  end
  
  def mod
    @comparision.mods[@index]
  end

  def first?
    index == 0 || mods[index - 1].model_key != mod.model_key
  end
  
  def next?
    index != 0 && mods[index - 1].model_key == mod.model_key
  end
  
  def mid?
    next? && !last?
  end
  
  def last?
    mod == mods.last || mods[index + 1].model_key != mod.model_key
  end
end

# "skoda fabia 2010 hatch_5d 1.6i-105ps-AT-FWD": {
#   "top_speed": 185,
#   "acceleration_0_100_kmh": 11.5,
#   "consumption_city": 10.2,
#   "consumption_highway": 6.1,
#   "consumption_mixed": 7.6,
#   "engine_volume": 1598,
#   "fuel": "petrol",
#   "fuel_rating": "A95",
#   "cylinder_count": 4,
#   "cylinder_placement": "inline",
#   "injection": "distributed_injection",
#   "engine_placement": "front_transversely",
#   "valves_per_cylinder": 4,
#   "compression": 10.5,
#   "bore": 76.5,
#   "max_power": 105,
#   "max_power_kw": 77,
#   "max_power_range_start": 5600,
#   "max_torque": 153,
#   "max_torque_range_start": 3800,
#   "transmission": "AT",
#   "gears": 6,
#   "drive_config": "FWD",
#   "length": 4000,
#   "width": 1642,
#   "height": 1498,
#   "ground_clearance": 149,
#   "tires": "185/60/R14,195/55/R15",
#   "front_tire_rut": 1433,
#   "rear_tire_rut": 1426,
#   "wheelbase": 2451,
#   "luggage_min": 315,
#   "luggage_max": 1180,
#   "tank_capacity": 45,
#   "gross_mass": 1650,
#   "kerbweight": 1135,
#   "front_suspension": "independent_coil",
#   "rear_suspension": "semidependent_coil",
#   "front_brakes": "disc_ventilated",
#   "rear_brakes": "drum",
#   "countries": "Чехия Россия",
#   "body_type": "хэтчбек",
#   "car_class": "В",
#   "doors": "5",
#   "seats": "5",
#   "produced_since": "Июнь 2010",
#   "model_title": "Skoda Fabia",
#   "body_title": "хэтчбек 5 дв",
#   "engine_title": "Ambition",
#   "engine_spec": "1.6 AT (105 л.с.)",
#   "price": "549 000 руб."
# },
