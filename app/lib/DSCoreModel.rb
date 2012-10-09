class DSCoreModel < NSManagedObject
  class << self
    def entityName
      @entityName ||= name
    end
    
    def defaultSortField
      @defaultSortField
    end
    
    def fields
      @fields
    end

    def entity
      @entity ||= NSEntityDescription.alloc.init.tap do |entity|
        entity.name = entityName
        entity.managedObjectClassName = entityName
        entity.properties = fields.map do |name, type, required|
          property = NSAttributeDescription.alloc.init
          property.name = name
          property.attributeType = type
          property.optional = !required
          property
        end
      end
    end
    
    def context
      Hel.delegate.objectContext
    end
    
    def save
      Hel.delegate.saveObjectContext
    end
    
    def create(attributes = {})
      # object = NSManagedObject.alloc.initWithEntity(entity, insertIntoManagedObjectContext:context)
      object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext:context)
      attributes.each { |name, value| object.send("#{name}=", value)}
      save
      reset
      object
    end  
    
    def delete(object)
      context.deleteObject(object)
      save
      reset
    end
    
    def deleteAll
      all.each { |object| context.deleteObject(object) }
      save
      reset
    end    
    
    def all
      @all ||= begin
        request = NSFetchRequest.alloc.init
        request.entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext:context)
        request.sortDescriptors = [NSSortDescriptor.alloc.initWithKey(defaultSortField, ascending:NO)]
        err = Hel.newErr
        unless results = context.executeFetchRequest(request, error:err)
          raise "Error when fetching data: #{err[0].description}"
        end
        results
      end
    end  
    
    def reset
      @all = nil
    end
    
    def count
      all.count
    end
    
    def first
      all.first
    end
  end

  def realClass
    NSClassFromString(entity.managedObjectClassName)
  end

  def delete
    realClass.delete(self)
  end
  
  def save
    realClass.save
  end  
  
  def updateAttributes(attributes = {})
    attributes.each { |attr, val| send("#{attr}=", val) }
    save
  end
end
