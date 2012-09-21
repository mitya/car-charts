class Disk
  class << self
    ### Things stored in the defaults

    def filterOptions
      NSUserDefaults.standardUserDefaults["filterOptions"] || {}
    end

    def filterOptions=(hash)
      NSUserDefaults.standardUserDefaults["filterOptions"] = hash
    end
  
    def currentMods
      @currentMods ||= NSUserDefaults.standardUserDefaults["mods"].to_a.map { |key| Modification.by(key) }
    end

    def currentMods=(array)
      NSUserDefaults.standardUserDefaults["mods"] = array.map(&:key)
      @currentMods = array
    end
  
    def recentMods
      @recentMods ||= NSUserDefaults.standardUserDefaults["recentMods"].to_a.map { |key| Modification.by(key) }
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
      @currentParameters ||= NSUserDefaults.standardUserDefaults["parameters"].to_a.map { |key| Parameter.by(key.to_sym) }
    end
  
    def currentParameters=(array)
      NSUserDefaults.standardUserDefaults["parameters"] = array.map { |p| p.key.to_s }
      @currentParameters = array
    end
  
    #### Initialization
  
    def load
      Hel.benchmark "Load All" do
        [Metadata, Brand, Model, Modification, Parameter].each { |klass| Hel.benchmark("Load #{klass.name}") { klass.load } }
      end
    end
  end
end
