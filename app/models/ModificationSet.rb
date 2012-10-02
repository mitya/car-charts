class ModificationSet
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def save
    NSUserDefaults.standardUserDefaults["modSets"] = NSUserDefaults.standardUserDefaults["modSets"].merge(@name => mods)
  end
  
  def delete
    NSUserDefaults.standardUserDefaults["modSets"] = NSUserDefaults.standardUserDefaults["modSets"].reject { |k,v| k == name }
  end
  
  def mods
    @mods ||= begin 
      modKeys = NSUserDefaults.standardUserDefaults["modSets"][name]
      modKeys.to_a.map { |key| Modification.by(key) }
    end
  end
  
  class << self
    def all
      plistItems = (NSUserDefaults.standardUserDefaults["modSets"] ||= {})
      plistItems.keys.map { |name| ModificationSet.new(name) }
    end
  end
end
