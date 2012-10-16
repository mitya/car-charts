class ModificationSet
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def position
    ES.defaults["modSetNames"].index(@name)
  end
  
  def save
    ES.defaults["modSets"] = ES.defaults["modSets"].merge(@name => mods.map(&:key))
    ES.defaults["modSetNames"] = (ES.defaults["modSetNames"] + [name]).sort unless ES.defaults["modSetNames"].include?(name)
  end
  
  def delete
    ES.defaults["modSets"] = ES.defaults["modSets"].reject { |k,v| k == name }
    ES.defaults["modSetNames"] = ES.defaults["modSetNames"].reject { |n| n == name }
  end
  
  def renameTo(newName)
    return if newName.blank? || ES.defaults["modSets"].include?(newName)
    
    modSets = ES.defaults["modSets"].reject { |k,v| k == name }
    modSets[newName] = mods.map(&:key)
    modSetNames = ES.defaults["modSetNames"].dup
    modSetNames[modSetNames.index(name)] = newName
    
    @name = newName
    ES.defaults["modSets"] = modSets
    ES.defaults["modSetNames"] = modSetNames.sort
  end
  
  def mods
    @mods ||= Mod.modsForKeys ES.defaults["modSets"][name]
  end
  
  def mods=(objects)
    @mods = objects
    save
  end
  
  def deleteMod(mod)
    @mods.delete(mod)
    save
  end
  
  def swapMods(from, to)
    a, b = mods[from], mods[to]
    @mods[from], @mods[to] = b, a
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
      ES.defaults["modSetNames"] ||= []
      ES.defaults["modSets"] ||= {}
      ES.defaults["modSetNames"].sort.map { |name| ModificationSet.new(name) }
    end
    
    def swap(from, to)
      list = ES.defaults["modSetNames"].dup
      a, b = list[to], list[from]
      list[to], list[from] = b, a
      ES.defaults["modSetNames"] = list
    end
  end
end
