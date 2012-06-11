class Modification
  attr_accessor :data
  attr_accessor :brand_key, :model_key, :body, :engine_vol, :fuel, :power, :transmission, :drive
  
  def initialize(data)
    @data = data
    parse_key
  end
  
  def key
    @data['key']
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
  
  def fuel_suffix
    fuel == 'i' ? '' : 'd'
  end
  
  AutomaticTransmissions = %w(AT AMT CVT)
  def automatic?
    AutomaticTransmissions.include?(@transmission)
  end
  
  def [](key)
    data[key]
  end
  
  private
  
  # alfa_romeo--159--2005--sedan---1.8i-140ps-MT-FWD
  # [alfa_romeo, 159, 2005, sedan, 1.8, i, 140, MT, FWD]
  # [alfa_romeo--159]
  def parse_key
    model_info, agregate_info = key.split('---')
    
    @brand_key, model_subkey, years, @body = model_info.split('--')
    @model_key = [@brand_key, model_subkey].join('--')
    
    engine, power, @transmission, @drive = agregate_info.split('-')
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

  def model_names
    @metadata['model_names']
  end

  def body_names
    @metadata['body_names']
  end
  
  def modification_for(key)
    @modifications_by_mod_key[key]
  end
  
  def load
    modification_hashes = NSMutableArray.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("modifications", ofType:"plist"))
    @modifications = modification_hashes.map { |hash| Modification.new(hash) }
        
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

class Comparision
  attr_accessor :mods, :params, :param
  
  def initialize(mods, params)
    @mods = mods
    @params = params
    @param = params.first
  end
  
  def values
    @values ||= mods.map { |mod| mod[param] }.compact
  end
  
  def max_value
    @max_value ||= values.max
  end

  def min_value
    @min_value ||= values.min
  end
end
