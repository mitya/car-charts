class ModelManager
  attr_accessor :modifications, :modifications_by_mod_key, :modifications_by_model_key, :metadata, :recent_mod_keys

  def brand_names
    Static.brand_names
  end
  
  def premium_brands
    @premium_brands ||= NSSet.setWithArray(Static.premium_brands)
  end

  def model_names
    @metadata['model_names']
  end
  
  def model_names_branded
    Model.metadata['model_names_branded']
  end
  
  def all_model_keys
    @all_model_keys ||= @metadata['model_names'].keys.sort
  end
  
  def model_classes
    Model.metadata['model_classes_inverted']
  end

  def body_names
    Static.body_names
  end
  
  def modification_for(key)
    @modifications_by_mod_key[key]
  end

  def unit_name_for(param)
    unit = Static.parameter_units[param.to_sym]
    Static.parameter_unit_names[unit]
  end
  
  def parameters
    @parameters ||= Static.parameter_names.map { |key, name| Parameter.new(key, name) }
  end

  def current_mods
    current_mod_keys.map { |m| modification_for(m) }
  end
  
  def current_mod_keys
    NSUserDefaults.standardUserDefaults["mods"] || []
  end

  def current_mod_keys=(array)
    NSUserDefaults.standardUserDefaults["mods"] = array
  end
  
  def toggle_mod_with_key(mod_key)
    if current_mod_keys.include?(mod_key)
      recent_mod_keys.delete(mod_key)
      recent_mod_keys << mod_key
    end    
    self.current_mod_keys = current_mod_keys.copyWithToggled(mod_key)
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
    
    @recent_mod_keys = []
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
