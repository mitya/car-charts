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
      @currentMods ||= Mod.byKeys NSUserDefaults.standardUserDefaults["mods"]
    end

    def currentMods=(array)
      NSUserDefaults.standardUserDefaults["mods"] = array.map(&:key)
      @currentMods = array
    end
  
    def recentMods
      @recentMods ||= Mod.byKeys NSUserDefaults.standardUserDefaults["recentMods"]
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
        [Metadata, Brand, Model, Parameter].each { |klass| Hel.benchmark("Load #{klass.name}") { klass.load } }
      end
      
      # keys = Modification.all.pluck(:key).sample(30)
      # 
      # Hel.benchmark "Search in-memory" do
      #   keys.map { |key| Mod.by(key) }.map { |m| m.body }
      # end
      # 
      # Hel.benchmark "Search DB" do
      #   keys.map { |key| Mod.by(key) }.map { |m| m.body }
      # end
      # 
      # Hel.benchmark "Search DB Mass" do
      #   Mod.byKeys(keys).map { |m| m.body }
      # end
      
    end
  end
end
