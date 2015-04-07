class Disk
  MaxRecentModCount = 30
  
  class << self
    def filterOptions
      NSUserDefaults.standardUserDefaults["filterOptions"] || {}
    end

    def filterOptions=(hash)
      changeValueForKey('filterOptions') do
        NSUserDefaults.standardUserDefaults["filterOptions"] = hash
      end
    end
  
    # sort order is not specified
    def currentMods
      @currentMods ||= Mod.modsForKeys(NSUserDefaults.standardUserDefaults["mods"].to_a).compact
    end

    def currentMods=(array)
      changeValueForKey('currentMods') do
        array.sort_by!(&:key)
        NSUserDefaults.standardUserDefaults["mods"] = array.map(&:key)
        @currentMods = array
      end
    end
    
    def removeModsFromCurrent(mod)
      self.currentMods = currentMods - Array(mod)
    end
  
    # sort order is not specified
    def recentMods
      @recentMods ||= Mod.modsForKeys(NSUserDefaults.standardUserDefaults["recentMods"].to_a).compact
    end

    def recentMods=(array)
      changeValueForKey('recentMods') do
        array = array.last(MaxRecentModCount)
        NSUserDefaults.standardUserDefaults["recentMods"] = array.map(&:key)
        @recentMods = array
      end
    end
  
    def toggleModInCurrentList(mod)
      self.recentMods = recentMods.dupWithToggledObject(mod) if currentMods.include?(mod) || recentMods.include?(mod)
      self.currentMods = currentMods.dupWithToggledObject(mod)
    end

    def currentParameters
      @currentParameters ||= NSUserDefaults.standardUserDefaults["parameters"].to_a.map { |key| Parameter.parameterForKey(key) }.compact
    end
  
    def currentParameters=(array)
      changeValueForKey('currentParameters') do
        NSUserDefaults.standardUserDefaults["parameters"] = array.map { |p| p.key.to_s }
        @currentParameters = array
      end
    end
    
    # SI UK UK
    def unitSystem
      NSUserDefaults.standardUserDefaults["unitSystem"] || 'SI'
    end
    
    def unitSystem=(value)
      changeValueForKey('unitSystem') do
        NSUserDefaults.standardUserDefaults["unitSystem"] = value
      end
    end
  

    def load
      [Metadata, Brand, Category, ModelFamily, ModelGeneration, Parameter].each do |klass|
        KK.benchmark("Load #{klass.name}") { klass.load }
      end
      
      self.currentParameters ||= []
      self.currentMods ||= []      

      if KK.env?('TestModsDataset') && KK.env?('TestModsDatasetRun')
        Mod.import
      end

      if firstLaunch?
        ModSet.create name:"Business (Sample)", modKeys:Metadata.sample_sets[:business]
        ModSet.create name:"Compact (Sample)", modKeys:Metadata.sample_sets[:compact]
        ModSet.create name:"SUVs (Sample)", modKeys:Metadata.sample_sets[:lux_suvs]

        ModSet.first.replaceCurrentMods

        self.currentParameters = %w(acceleration_100kmh max_power).map { |key| Parameter.parameterForKey(key) }

        NSUserDefaults.standardUserDefaults["firstLaunchTime"] = Time.now
        NSUserDefaults.standardUserDefaults.synchronize
      end
    end
    
    def firstLaunch?
      NSUserDefaults.standardUserDefaults["firstLaunchTime"].nil? && 
      NSUserDefaults.standardUserDefaults["mods"].nil? && 
      NSUserDefaults.standardUserDefaults["recentMods"].nil? && 
      NSUserDefaults.standardUserDefaults["parameters"].nil? && 
      ModSet.count == 0
    end
    
    private 
    
    def changeValueForKey(key)
      willChangeValueForKey(key)
      yield
      NSUserDefaults.standardUserDefaults.synchronize
      didChangeValueForKey(key)
    end
  end
end
