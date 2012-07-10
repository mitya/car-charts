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
  
  def current_models
    NSUserDefaults.standardUserDefaults["models"] || []
  end

  def current_models=(array)
    NSUserDefaults.standardUserDefaults["models"] = array
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
