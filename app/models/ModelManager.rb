class ModelManager
  attr_accessor :metadata

  def premiumBrandKeys
    @premiumBrandKeys ||= NSSet.setWithArray(Metadata.premiumBrandKeys)
  end

  def unit_name_for(param)
    unit = Metadata.parameter_units[param.to_sym]
    Metadata.parameter_unit_names[unit]
  end
  
  def parameters
    @parameters ||= Metadata.parameter_names.map { |key, name| Parameter.new(key, name) }
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
  
  def currentParameters
    NSUserDefaults.standardUserDefaults["parameters"] || []
  end
  
  def currentParameters=(array)
    NSUserDefaults.standardUserDefaults["parameters"] = array
  end
  
  #### Initialization
  
  def load
    Metadata.load
    Modification.load
  end
end

Model = ModelManager.new
