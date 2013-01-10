class Disk
  MaxRecentModCount = 30
  
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
      array = array.last(MaxRecentModCount)
      NSUserDefaults.standardUserDefaults["recentMods"] = array.map(&:key)      
      @recentMods = array
    end
  
    def toggleModInCurrentList(mod)
      self.recentMods = recentMods.dupWithToggledObject(mod) if currentMods.include?(mod) || recentMods.include?(mod)
      self.currentMods = currentMods.dupWithToggledObject(mod)
      NSUserDefaults.standardUserDefaults.synchronize
    end

    def currentParameters
      @currentParameters ||= NSUserDefaults.standardUserDefaults["parameters"].to_a.map { |key| Parameter.parameterForKey(key.to_sym) }
    end
  
    def currentParameters=(array)
      willChangeValueForKey('currentParameters')
      NSUserDefaults.standardUserDefaults["parameters"] = array.map { |p| p.key.to_s }
      NSUserDefaults.standardUserDefaults.synchronize
      @currentParameters = array
      didChangeValueForKey('currentParameters')
    end
  

    def load
      ES.benchmark "Load All" do
        [Metadata, Brand, Category, Model, Parameter].each { |klass| ES.benchmark("Load #{klass.name}") { klass.load } }
      end     
      self.currentParameters ||= []
      self.currentMods ||= []      

      if NSUserDefaults.standardUserDefaults["firstLaunchTime"].nil? && 
           NSUserDefaults.standardUserDefaults["mods"].nil? && 
           NSUserDefaults.standardUserDefaults["recentMods"].nil? && 
           NSUserDefaults.standardUserDefaults["parameters"].nil? && 
           ModSet.count == 0
        Mod.import if $devdata

        ModSet.create name:"Business (Sample)", modKeys:Metadata.sampleModSets[:business]
        ModSet.create name:"SUVs (Sample)", modKeys:Metadata.sampleModSets[:midSuvs]
        ModSet.create name:"Compact (Sample)", modKeys:Metadata.sampleModSets[:compact]
        ModSet.all.first.replaceCurrentMods

        self.currentParameters = %w(acceleration_100kmh max_power length).map { |key| Parameter.parameterForKey(key.to_sym) }

        NSUserDefaults.standardUserDefaults["firstLaunchTime"] = Time.now
        NSUserDefaults.standardUserDefaults.synchronize
      end
    end
  end
end
