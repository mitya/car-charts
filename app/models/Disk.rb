class Disk
  MaxRecentModCount = 30
  
  class << self
    def filterOptions
      NSUserDefaults.standardUserDefaults["filterOptions"] || {}
    end

    def filterOptions=(hash)
      changeValueForKey('filterOptions', notify:YES) do
        NSUserDefaults.standardUserDefaults["filterOptions"] = hash
      end
    end

  
    # sort order is not specified
    def currentMods
      @currentMods ||= Mod.modsForKeys(NSUserDefaults.standardUserDefaults["mods"].to_a).compact
    end

    def currentMods=(array)
      changeValueForKey('currentMods', notify:YES) do
        array.sort_by!(&:key)
        NSUserDefaults.standardUserDefaults["mods"] = array.map(&:key)
        @currentMods = array
      end
    end
    
    def removeModsFromCurrent(mod)
      self.recentMods = recentMods + Array(mod).select { |m| !recentMods.include?(mod) }
      self.currentMods = currentMods - Array(mod)
    end
  
    # sort order is not specified
    def recentMods
      @recentMods ||= Mod.modsForKeys(NSUserDefaults.standardUserDefaults["recentMods"].to_a).compact
    end

    def recentMods=(array)
      changeValueForKey('recentMods', notify:YES) do
        array = array.last(MaxRecentModCount)
        NSUserDefaults.standardUserDefaults["recentMods"] = array.map(&:key)
        @recentMods = array
      end
    end
  
    def sortedRecentMods
      puts 'sorting recent mods'
      recentMods.sort_by(&:key)
    end
    
    def deselectAllCurrentMods
      self.recentMods = recentMods + currentMods
      self.currentMods = []      
    end
  
    def toggleModInCurrentList(mod)
      self.recentMods = recentMods.dupWithToggledObject(mod) if currentMods.include?(mod) || recentMods.include?(mod)
      self.currentMods = currentMods.dupWithToggledObject(mod)
    end


    def currentParameters
      @currentParameters ||= NSUserDefaults.standardUserDefaults["parameters"].to_a.map { |key| Parameter.parameterForKey(key) }.compact
    end
  
    def currentParameters=(array)
      changeValueForKey('currentParameters', notify:YES) do
        NSUserDefaults.standardUserDefaults["parameters"] = array.map { |p| p.key.to_s }
        @currentParameters = array
      end
    end
    
    
    # SI UK UK
    def unitSystem
      NSUserDefaults.standardUserDefaults["unitSystem"] || 'SI'
    end
    
    def unitSystem=(value)
      changeValueForKey('unitSystem', notify:YES) do
        NSUserDefaults.standardUserDefaults["unitSystem"] = value
      end
    end
    
    
    # Favorites
    
    def favorites
      @favorites ||= NSUserDefaults.standardUserDefaults["favorites"].to_a.map { |key| ModelGeneration[key] }
    end
    
    def syncFavorites
      NSUserDefaults.standardUserDefaults["favorites"] = @favorites.map(&:key)
    end
    
    def removeFromFavorites(generation, notify:notify)
      changeValueForKey('favorites', notify:notify) do
        @favorites.delete(generation)
        Dispatch::Queue.concurrent.async { syncFavorites }
      end      
    end
    
    def toggleInFavorites(generation)
      changeValueForKey('favorites', notify:YES) do
        if @favorites.include?(generation)
          @favorites.delete(generation)
        else
          @favorites.push(generation)
          @favorites.sort_by!(&:key)
        end
        Dispatch::Queue.concurrent.async { syncFavorites }
      end
    end
  

    def load
      [Metadata, Brand, Category, ModelFamily, ModelGeneration, Parameter].each do |klass|
        KK.benchmark("Load #{klass.name}") { klass.load }
      end
      
      self.currentParameters ||= []
      self.currentMods ||= []

      if KK.env?('CCTestModsDataset') && KK.env?('CCTestModsDatasetRun')
        Mod.import
      end

      if firstLaunch?
        self.currentParameters = %w(acceleration_100kmh max_power).map { |key| Parameter.parameterForKey(key) }
        NSUserDefaults.standardUserDefaults["favorites"] = Samples[:favorites]
        # set current mods
        
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
    
    def changeValueForKey(key, notify:notify)
      willChangeValueForKey(key) if notify
      yield
      Dispatch::Queue.concurrent.async { NSUserDefaults.standardUserDefaults.synchronize }
      didChangeValueForKey(key) if notify
    end
  end
end
