class NSManagedObjectContext
  def fetchEntity(entity, predicate:predicateArgs)
    fetchRequest = NSFetchRequest.alloc.init
    fetchRequest.entity = NSEntityDescription.entityForName(entity.name, inManagedObjectContext:self)
    fetchRequest.predicate = NSPredicate.predicateWithFormat(predicateArgs.first, argumentArray:predicateArgs.tail)
    error = ES.ptr
    executeFetchRequest(fetchRequest, error:error) || raise("Error when fetching data: #{error.value.description}")
  end
end