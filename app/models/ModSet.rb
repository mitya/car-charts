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
    updateAttributes name:newName, reset:YES
  end

  def modKeys
    @modKeys ||= (modKeysString || "").split(',')
  end

  def modCount
    modKeys.count
  end

  def mods
    @mods ||= modKeys.map { |key| Modification.by(key) }
  end

  def mods=(objects)
    @modKeys = @mods = nil
    updateAttributes modKeysString:objects.pluck(:key).join(',')
  end

  def deleteMod(mod)
    updateAttributes mods:mods.reject{ |obj| obj == mod }
  end

  def swapMods(index1, index2)
    updateAttributes mods:mods.swap(index1, index2)
  end

  def replaceCurrentMods
    Disk.currentMods = mods
  end

  def addToCurrentMods
    Disk.currentMods = Disk.currentMods | mods
  end
  
  def self.byName(name)
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)
    request.predicate = NSPredicate.predicateWithFormat("name = %@", argumentArray:[name])
    err = Hel.newErr
    unless results = context.executeFetchRequest(request, error:err)
      raise "Error when fetching data: #{err[0].description}"
    end
    results.first
  end
end
