class ModelManager
  attr_accessor :metadata

  def premiumBrandKeys
    @premiumBrandKeys ||= NSSet.setWithArray(Static.premiumBrandKeys)
  end

  def body_names
    Static.body_names
  end
  
  def unit_name_for(param)
    unit = Static.parameter_units[param.to_sym]
    Static.parameter_unit_names[unit]
  end
  
  def parameters
    @parameters ||= Static.parameter_names.map { |key, name| Parameter.new(key, name) }
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

  ### Things stored in defaults

  def filterOptions
    NSUserDefaults.standardUserDefaults["filterOptions"] || {}
  end

  def filterOptions=(hash)
    NSUserDefaults.standardUserDefaults["filterOptions"] = hash
  end
  
  def currentMods
    @currentMods ||= Modification.getMany( NSUserDefaults.standardUserDefaults["mods"] || [] )
  end

  def currentMods=(array)
    NSUserDefaults.standardUserDefaults["mods"] = array.map(&:key)
    @currentMods = array
  end
  
  def recentMods
    @recentMods ||= Modification.getMany( NSUserDefaults.standardUserDefaults["recentMods"] || [] )
  end

  def recentMods=(array)
    NSUserDefaults.standardUserDefaults["recentMods"] = array.map(&:key)
    @recentMods = array
  end
  
  def toggleMod(mod)
    self.recentMods = recentMods.copyWithToggled(mod) if currentMods.include?(mod) || recentMods.include?(mod)
    self.currentMods = currentMods.copyWithToggled(mod)
  end
  
  def current_parameters
    NSUserDefaults.standardUserDefaults["parameters"] || []
  end
  
  def current_parameters=(array)
    NSUserDefaults.standardUserDefaults["parameters"] = array
  end
  
  #### Initialization
  
  def load
    @metadata = NSDictionary.alloc.initWithContentsOfFile(NSBundle.mainBundle.pathForResource("db-metadata", ofType:"plist"))
    Modification.load
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
