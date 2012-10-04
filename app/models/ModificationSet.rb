class ModificationSet
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def position
    Hel.defaults["modSetNames"].index(@name)
  end
  
  def save
    Hel.defaults["modSets"] = Hel.defaults["modSets"].merge(@name => mods.map(&:key))
    Hel.defaults["modSetNames"] = (Hel.defaults["modSetNames"] + [name]).sort unless Hel.defaults["modSetNames"].include?(name)
  end
  
  def delete
    Hel.defaults["modSets"] = Hel.defaults["modSets"].reject { |k,v| k == name }
    Hel.defaults["modSetNames"] = Hel.defaults["modSetNames"].reject { |n| n == name }
  end
  
  def renameTo(newName)
    return if newName.blank? || Hel.defaults["modSets"].include?(newName)
    
    modSets = Hel.defaults["modSets"].reject { |k,v| k == name }
    modSets[newName] = mods.map(&:key)
    modSetNames = Hel.defaults["modSetNames"].dup
    modSetNames[modSetNames.index(name)] = newName
    
    @name = newName
    Hel.defaults["modSets"] = modSets
    Hel.defaults["modSetNames"] = modSetNames.sort
  end
  
  def mods
    @mods ||= Hel.defaults["modSets"][name].to_a.map { |key| Modification.by(key) }
  end
  
  def mods=(objects)
    @mods = objects
    save
  end
    
  def replaceCurrentMods
    Disk.currentMods = mods
  end
  
  def addToCurrentMods
    Disk.currentMods = Disk.currentMods | mods
  end
  
  class << self
    def all
      Hel.defaults["modSetNames"] ||= []
      Hel.defaults["modSets"] ||= {}
      Hel.defaults["modSetNames"].sort.map { |name| ModificationSet.new(name) }
    end
    
    def swap(from, to)
      list = Hel.defaults["modSetNames"].dup
      a, b = list[to], list[from]
      list[to], list[from] = b, a
      Hel.defaults["modSetNames"] = list
    end
  end
end
