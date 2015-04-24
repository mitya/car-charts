class NSManagedObjectContext
  def fetchEntity(entity, predicate:predicateArgs, order:sortField)
    fetchRequest = NSFetchRequest.fetchRequestWithEntityName(entity.name)    
    fetchRequest.predicate = NSPredicate.predicateWithFormat(predicateArgs.first, argumentArray:predicateArgs.tail)

    if sortField
      asc = !sortField.start_with?('-')
      sortField = sortField[1..-1] if !asc
      fetchRequest.sortDescriptors = [NSSortDescriptor.alloc.initWithKey(sortField, ascending:asc)]
    end    
    
    error = KK.ptr
    unless results = executeFetchRequest(fetchRequest, error:error)
       NSLog("Error when fetching data: #{error.value.description}")
       Flurry.logError 'Fetch Error', message:error.value.description, error:error
    end 
    results || []
  end

  def fetchEntity(entity, predicate:predicateArgs)
    fetchEntity(entity, predicate:predicateArgs, order:NIL)
  end
end
