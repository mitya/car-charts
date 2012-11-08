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
    
    # def leaveMaxMinusOneRecentModsIfNeeded
    #   originalRecentModCount = recentMods.size
    #   if originalRecentModCount >= MaxRecentModCount
    #     self.recentMods = recentMods.last(MaxRecentModCount - 1)
    #     originalRecentModCount - MaxRecentModCount + 1
    #   else
    #     0
    #   end
    # end
  
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
      self.currentParameters ||= [Parameter.parameterForKey(:max_power)]
      self.currentMods ||= []      
      
      # NSUserDefaults.standardUserDefaults["mods"] = [ 
      #   "alfa_romeo 147 2004-2010 hatch_3d 2.0i-150ps-AMT-FWD", 
      #   "alfa_romeo gt 2003 coupe 2.0i-165ps-AMT-FWD",
      #   "acura rdx 2006-2009 suv 2.3i-240ps-AT-4WD", 
      #   "acura tl 2009 sedan 3.5i-280ps-AT-FWD", 
      #   "audi a4 2011 sedan 2.0i-211ps-MT-FWD", 
      #   "bmw x5 2010 crossover 3.0d-381ps-AT-4WD", 
      #   "chrysler pt_cruiser 2005-2010 hatch_5d 1.6i-116ps-MT-FWD", 
      # ]
      # NSUserDefaults.standardUserDefaults["recentMods"] = [
      #   "hyundai santa_fe 2010 crossover 2.2d-197ps-AT-4WD",
      #   "jeep liberty 2007 suv 2.4i-170ps-CVT-4WD",
      #   "porsche panamera 2009 hatch_5d 4.8i-430ps-AMT-4WD",
      #   "volkswagen touareg 2010 suv 3.6i-280ps-AT-4WD",
      #   "volkswagen golf 2009 hatch_3d 2.0d-110ps-MT-FWD",
      # ]
    end
  end
end
