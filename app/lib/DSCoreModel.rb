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
    
    def contextName
      @contextName || :userContext
    end
    
    def context
      ES.delegate.send(contextName)
    end
    
    def save
      ES.delegate.saveObjectContext(context)
    end
    
    def build(attributes = nil)
      # object = NSManagedObject.alloc.initWithEntity(entity, insertIntoManagedObjectContext:context)
      object = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext:context)
      attributes.each { |name, value| object.set(name, value) } if attributes
      object
    end
    
    def create(attributes = nil)
      object = build(attributes)
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
        request.sortDescriptors = [NSSortDescriptor.alloc.initWithKey(defaultSortField, ascending:YES)]
        err = ES.newErr
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

  # the instances returned by Core Data methods belongs to a proxy class that is derived from the real class
  def klass
    NSClassFromString(entity.managedObjectClassName)
  end

  def delete
    klass.delete(self)
  end
  
  def save
    klass.save
  end  
  
  def get(attr)
    valueForKey(attr)
  end
  
  def set(attr, value)
    setValue(value, forKey:attr)
  end
  
  def update(attributes = {})
    shouldReset = attributes.delete(:reset)
    attributes.each { |attr, val| set(attr, val) }
    save
    klass.reset if shouldReset
  end
end
