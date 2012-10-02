class ModificationSetsController < UITableViewController
  attr_accessor :sets

  def viewDidLoad
    super
    self.title = "Model Sets"
    navigationItem.rightBarButtonItem = Hel.systemBBI(UIBarButtonSystemItemAdd, target:self, action:'addNew')
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  def tableView(tv, numberOfRowsInSection:section)
    reloadSets
    @sets.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    cell = tv.dequeueReusableCell { |cl| cl.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
    cell.textLabel.text = set.name
    cell
  end

  def tableView(tv, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    if editingStyle == UITableViewCellEditingStyleDelete
      set = @sets[indexPath.row]
      set.delete
      reloadSets
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
    end 
  end

  ####
  
  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    if alertView.buttonTitleAtIndex(buttonIndex) == "OK"
      setTitle = alertView.textFieldAtIndex(0).text
      ModificationSet.new(setTitle).save
      tableView.reloadData
    end
  end
  
  private

  def addNew
    alertView = UIAlertView.alloc.initWithTitle("New Model Set",
      message:"Enter the set title", delegate:self, cancelButtonTitle:"Cancel", otherButtonTitles:nil)
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput
    alertView.addButtonWithTitle "OK"
    alertView.show
  end
  
  def reloadSets
    @sets = ModificationSet.all
  end
  
  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    tableView.deselectRowAtIndexPath indexPath, animated:YES    
    navigationController.pushViewController ModificationSetController.new(set), animated:YES
  end
end
