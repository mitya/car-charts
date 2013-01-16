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

  # def modKeys
  #   @modKeys ||= begin
  #     fetchRequest = NSFetchRequest.fetchRequestWithEntityName('ModProxy')
  #     fetchRequest.predicate = NSPredicate.predicateWithFormat("self in %@", argumentArray:[modProxies.valueForKeyPath("objectID").allObjects])
  #     modProxyObjects = self.class.context.executeFetchRequest(fetchRequest, error:NULL)
  #     modProxyObjects.map(&:modKey)
  #   end
  # end
  # 
  # def modKeys=(keys)
  #   @modKeys = @mods = nil
  #   self.modProxies = NSSet.setWithArray( keys.map { |key| ModProxy.build modKey:key } )
  # end
  # 
  # def modCount
  #   modProxies.count
  # end
  # 
  # def modPreviewString
  #   mods.map(&:model).uniq.map(&:unbrandedName).first(10).join(', ')
  # end
  # 
  # def mods
  #   @mods ||= Mod.unorderedModsForKeys(modKeys)
  # end
  # 
  # def mods=(objects)
  #   @modKeys = @mods = nil
  #   self.modKeys = objects.pluck(:key)
  # end
  # 
  # def deleteMod(mod)
  #   self.mods = mods.reject { |obj| obj == mod }
  # end
  # 
  # def swapMods(index1, index2)
  #   self.mods = mods.swap(index1, index2)
  # end

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
    mods.map(&:model).uniq.map(&:unbrandedName).first(10).join(', ')
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
  
  class ModProxy < DSCoreModel
    @entityName = "ModProxy"
    @defaultSortField = 'modKey'
    @fields = [
      ['modKey', NSStringAttributeType, false]
    ]
    
    def self.initRelationships
      modToSet = NSRelationshipDescription.alloc.init
      modToSet.name = "modSet"
      modToSet.destinationEntity = ModSet.entity
      modToSet.maxCount = 1
      
      setToMod = NSRelationshipDescription.alloc.init
      setToMod.name = "modProxies"
      setToMod.destinationEntity = ModSet::ModProxy.entity
      setToMod.maxCount = -1
      setToMod.deleteRule = NSCascadeDeleteRule

      setToMod.inverseRelationship = modToSet
      modToSet.inverseRelationship = setToMod
      
      ModSet.entity.properties = ModSet.entity.properties + [setToMod]
      ModSet::ModProxy.entity.properties = ModSet::ModProxy.entity.properties + [modToSet]
    end
  end
end
