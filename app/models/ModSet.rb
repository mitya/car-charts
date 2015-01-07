class ModSet < DSCoreModel
  @fields = [
    ['name', NSStringAttributeType, true],
    ['modKeysString', NSStringAttributeType, false]
  ]
  @defaultSortField = 'name'

  def position
    klass.all.index(self)
  end

  def renameTo(newName)
    return if newName == name || newName.blank? || klass.all.pluck(:name).include?(newName)
    update name:newName, reset:YES
  end

  def modKeys
    @modKeys ||= (modKeysString || "").split(',')
  end
  
  def modKeys=(keys)
    @modKeys = @mods = nil
    self.modKeysString = keys.join(',')
  end
  
  def modCount
    modKeys.count
  end
  
  def modPreviewString
    mods.map(&:model).uniq.map(&:unbrandedName).first(15).join(', ')
  end
  
  def mods
    @mods ||= Mod.unorderedModsForKeys(modKeys)
  end
  
  def mods=(objects)
    @modKeys = @mods = nil
    update modKeysString:objects.pluck(:key).join(',')
  end
  
  def deleteMod(mod)
    update mods:mods.reject{ |obj| obj == mod }
  end
  
  def swapMods(index1, index2)
    update mods:mods.swap(index1, index2)
  end

  def replaceCurrentMods
    Disk.currentMods = mods
  end

  def addToCurrentMods
    Disk.currentMods = Disk.currentMods | mods
  end
    
  def self.modSetForName(name)
    context.fetchEntity(entity, predicate:["name = %@", name]).first
  end
end
