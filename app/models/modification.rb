class Modification
  attr_accessor :data, :key
  attr_accessor :model, :body, :engine_vol, :fuel, :power, :transmission, :drive, :version_subkey
  
  def initialize(key, data)
    @key, @data = key, data
    parse_key
  end
  
  def full_name
    "#{model.name} #{nameNoBody}"
  end
  
  def nameNoBody
    "#{engine_vol}#{fuel_suffix}#{compressor_suffix} #{power}ps #{transmission}"
  end
  
  def nameWithVersion
    version_subkey ? "#{nameNoBody}, #{version_subkey}" : nameNoBody
  end
  
  def mod_name
    "#{nameNoBody}, #{version}"
  end
  
  def category
    Model.metadata['model_classes'][model.key]
  end
  
  def body_name
    Model.body_names[body] || "XXX #{body}"
  end
  
  def version
    @version ||= [body_name, version_subkey].join(' ')
  end
  
  def version_name
    data['version_name']
  end
  
  def fuel_suffix
    fuel == 'i' ? '' : 'd'
  end
  
  def compressor_suffix
    data['compressor'] && fuel != 'd' ? "T" : ""
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
    data[key]
  end
  
  def toggle
    Model.toggleMod(key)
  end
  
  private
  
  # alfa_romeo--159--2005--sedan---1.8i-140ps-MT-FWD
  # [alfa_romeo, 159, 2005, sedan, 1.8, i, 140, MT, FWD]
  # [alfa_romeo--159]
  def parse_key
    brand_key, model_version, years, @body, agregate = key.split(' ')
    model_subkey, @version_subkey = model_version.split('.')
    model_key = [brand_key, model_subkey].join('--')
    
    @model = Make.get(model_key)
    
    engine, power, @transmission, @drive = agregate.split('-')
    @engine_vol = engine[0..-2]
    @fuel = engine[-1]
    @power = power.to_i
  end
  
  AutomaticTransmissions = %w(AT AMT CVT)  

  class << self
    def get(key)
      @@map[key]
    end

    def getMany(keys)
      keys.map { |k| get(k) }
    end
  
    def all
      @@all
    end
  
    def map
      @@map
    end
  
    def load
      plist = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db-modifications", ofType:"plist"))
      @@all = plist.map { |key, data| new(key, data) }
  
      @@map = {}
      @@all.each do |mod|
        @@map[mod.key] = mod
        mod.model.modifications << mod
      end        
    end    
  end
end
