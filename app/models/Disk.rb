class Disk
  class << self
    def filterOptions
      NSUserDefaults.standardUserDefaults["filterOptions"] || {}
    end

    def filterOptions=(hash)
      NSUserDefaults.standardUserDefaults["filterOptions"] = hash
    end
  
    def currentMods
      @currentMods ||= Mod.modsForKeys(NSUserDefaults.standardUserDefaults["mods"].to_a)
    end

    def currentMods=(array)
      willChangeValueForKey('currentMods')
      NSUserDefaults.standardUserDefaults["mods"] = array.map(&:key)
      @currentMods = array
      didChangeValueForKey('currentMods')
    end
  
    def recentMods
      @recentMods ||= Mod.modsForKeys(NSUserDefaults.standardUserDefaults["recentMods"].to_a)
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
      @currentParameters ||= NSUserDefaults.standardUserDefaults["parameters"].to_a.map { |key| Parameter.parameterForKey(key.to_sym) }
    end
  
    def currentParameters=(array)
      willChangeValueForKey('currentParameters')
      NSUserDefaults.standardUserDefaults["parameters"] = array.map { |p| p.key.to_s }
      @currentParameters = array
      didChangeValueForKey('currentParameters')
    end
  

    def load
      ES.benchmark "Load All" do
        [Metadata, Brand, Category, Model, Parameter].each { |klass| ES.benchmark("Load #{klass.name}") { klass.load } }
      end
    end
  end
end
