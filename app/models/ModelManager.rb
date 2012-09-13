class ModelManager
  ### Things stored in the defaults

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
  
  def toggleModInCurrentList(mod)
    self.recentMods = recentMods.dupWithToggledObject(mod) if currentMods.include?(mod) || recentMods.include?(mod)
    self.currentMods = currentMods.dupWithToggledObject(mod)
  end
  
  def currentParameters
    @currentParameters ||= Parameter.getMany( (NSUserDefaults.standardUserDefaults["parameters"] || []).map(&:to_sym) )
  end
  
  def currentParameters=(array)
    NSUserDefaults.standardUserDefaults["parameters"] = array.map { |p| p.key.to_s }
    @currentParameters = array
  end
  
  #### Initialization
  
  def load
    Hel.benchmark("Metadata Load") { Metadata.load }
    Hel.benchmark("Modification Load") { Modification.load }
    Hel.benchmark("Parameter Load") { Parameter.load }
  end
end

Model = ModelManager.new
