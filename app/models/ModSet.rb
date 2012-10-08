# p NSDateAttributeType
# p NSStringAttributeType

class ModSet < NSManagedObject
  def self.entity
    return @entity if @entity
    entity = NSEntityDescription.alloc.init
    entity.name = 'ModSet'
    entity.managedObjectClassName = 'ModSet'
    entity.properties = 
      [
        ['name', NSStringAttributeType, true],
        ['mods', NSStringAttributeType, false]
      ].map do |name, type, required|
        property = NSAttributeDescription.alloc.init
        property.name = name
        property.attributeType = type
        property.optional = !required
        property
      end
    @entity = entity
  end 

  def self.create(name)
    object = NSEntityDescription.insertNewObjectForEntityForName('ModSet', inManagedObjectContext:Hel.delegate.objectContext)
    object.name = name
    Hel.delegate.saveObjectContext
    @all = nil
    object
  end

  def self.all
    return @all if @all
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName('ModSet', inManagedObjectContext:Hel.delegate.objectContext)
    request.sortDescriptors = [NSSortDescriptor.alloc.initWithKey('name', ascending:NO)]

    errorPtr = Pointer.new(:object)
    @all = Hel.delegate.objectContext.executeFetchRequest(request, error:errorPtr)
    raise "Error when fetching data: #{errorPtr[0].description}" if @all == nil
    @all
  end
  
  def delete
    Hel.delegate.objectContext.deleteObject(self)
    Hel.delegate.saveObjectContext
    @all = nil
  end
  
  def position
    self.class.all.map(&:name).index(name)
  end
  
  # attr_reader :name
  # 
  # def initialize(name)
  #   @name = name
  # end
  # 
  # def position
  #   Hel.defaults["modSetNames"].index(@name)
  # end
  # 
  # def save
  #   Hel.defaults["modSets"] = Hel.defaults["modSets"].merge(@name => mods.map(&:key))
  #   Hel.defaults["modSetNames"] = (Hel.defaults["modSetNames"] + [name]).sort unless Hel.defaults["modSetNames"].include?(name)
  # end
  # 
  # def delete
  #   Hel.defaults["modSets"] = Hel.defaults["modSets"].reject { |k,v| k == name }
  #   Hel.defaults["modSetNames"] = Hel.defaults["modSetNames"].reject { |n| n == name }
  # end
  # 
  # def renameTo(newName)
  #   return if newName.blank? || Hel.defaults["modSets"].include?(newName)
  #   
  #   modSets = Hel.defaults["modSets"].reject { |k,v| k == name }
  #   modSets[newName] = mods.map(&:key)
  #   modSetNames = Hel.defaults["modSetNames"].dup
  #   modSetNames[modSetNames.index(name)] = newName
  #   
  #   @name = newName
  #   Hel.defaults["modSets"] = modSets
  #   Hel.defaults["modSetNames"] = modSetNames.sort
  # end
  # 
  # def mods
  #   @mods ||= Hel.defaults["modSets"][name].to_a.map { |key| Modification.by(key) }
  # end
  # 
  # def mods=(objects)
  #   @mods = objects
  #   save
  # end
  # 
  # def deleteMod(mod)
  #   @mods.delete(mod)
  #   save
  # end
  # 
  # def swapMods(from, to)
  #   a, b = mods[from], mods[to]
  #   @mods[from], @mods[to] = b, a
  #   save
  # end
  #   
  # def replaceCurrentMods
  #   Disk.currentMods = mods
  # end
  # 
  # def addToCurrentMods
  #   Disk.currentMods = Disk.currentMods | mods
  # end
  # 
  # class << self
  #   def all
  #     Hel.defaults["modSetNames"] ||= []
  #     Hel.defaults["modSets"] ||= {}
  #     Hel.defaults["modSetNames"].sort.map { |name| ModificationSet.new(name) }
  #   end
  #   
  #   def swap(from, to)
  #     list = Hel.defaults["modSetNames"].dup
  #     a, b = list[to], list[from]
  #     list[to], list[from] = b, a
  #     Hel.defaults["modSetNames"] = list
  #   end
  # end
end
