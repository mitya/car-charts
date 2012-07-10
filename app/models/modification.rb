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
