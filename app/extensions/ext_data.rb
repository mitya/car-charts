class NSManagedObjectContext
  def fetchEntity(entity, predicate:predicateArgs, order:sortField)
    fetchRequest = NSFetchRequest.fetchRequestWithEntityName(entity.name)    
    fetchRequest.predicate = NSPredicate.predicateWithFormat(predicateArgs.first, argumentArray:predicateArgs.tail)

    if sortField
      asc = !sortField.start_with?('-')
      sortField = sortField[1..-1] if !asc
      fetchRequest.sortDescriptors = [NSSortDescriptor.alloc.initWithKey(sortField, ascending:asc)]
    end    
    
    error = ES.ptr
    executeFetchRequest(fetchRequest, error:error) || raise("Error when fetching data: #{error.value.description}")
  end

  def fetchEntity(entity, predicate:predicateArgs)
    fetchEntity(entity, predicate:predicateArgs, order:NIL)
  end
end
