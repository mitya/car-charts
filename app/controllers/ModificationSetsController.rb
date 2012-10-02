class ModificationSetsController < UITableViewController
  attr_accessor :sets

  def initialize
  end

  def viewDidLoad
    super
    self.title = "Model Sets"
    navigationItem.rightBarButtonItem = Hel.systemBBI(UIBarButtonSystemItemAdd, target:self, action:'showNewSetDialog')
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  def tableView(tv, numberOfRowsInSection:section)
    @sets = ModificationSet.all
    @sets.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    cell = tv.dequeueReusableCell { |cl| cl.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
    cell.textLabel.text = set.name
    cell
  end

  private

  def showNewSetDialog
    alertView = UIAlertView.alloc.initWithTitle("New Model Set",
      message:"Enter the set title", delegate:self, cancelButtonTitle:"Cancel", otherButtonTitles:nil)
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput
    alertView.addButtonWithTitle "OK"
    alertView.show
  end
  
  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    if alertView.buttonTitleAtIndex(buttonIndex) == "OK"
      setTitle = alertView.textFieldAtIndex(0).text
      ModificationSet.new(setTitle).save
      tableView.reloadData
    end
  end
  
  # def tableView(tv, didSelectRowAtIndexPath:indexPath)
  #   tv.deselectRowAtIndexPath(indexPath, animated:true)
  # 
  #   bodyKey = modsByBody.keys[indexPath.section]
  #   mod = modsByBody[bodyKey][indexPath.row]
  #   Disk.toggleModInCurrentList(mod)
  # 
  #   cell = tv.cellForRowAtIndexPath(indexPath)
  #   cell.toggleCheckmarkAccessory
  # end
end
