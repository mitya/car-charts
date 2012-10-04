class ModSetsController < UITableViewController
  attr_accessor :sets

  def viewDidLoad
    super
    self.title = "Model Sets"
    navigationItem.rightBarButtonItems = [editButtonItem, Hel.systemBBI(UIBarButtonSystemItemAdd, target:self, action:'addNew')]
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
    if isEditing
      cell = tv.dequeueReusableCell(id: "EditorCell") do |cell|
        textField = UITextField.alloc.initWithFrame(CGRectMake(40, 0, 200, 43))
        textField.font = UIFont.boldSystemFontOfSize(20)
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter
        textField.placeholder = "Set Title"
        textField.tag = 1
        textField.delegate = self
        textField.returnKeyType = UIReturnKeyDone
        textField.enablesReturnKeyAutomatically = true
        cell.addSubview textField
      end
      textField = cell.viewWithTag(1)
      textField.text = set.name
    else
      cell = tv.dequeueReusableCell(klass: BadgeViewCell) { |cl| cl.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
      cell.text = set.name
      cell.badgeText = set.mods.count
    end
    cell    
  end

  def tableView(tv, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    case editingStyle when UITableViewCellEditingStyleDelete
      set = @sets[indexPath.row]
      set.delete
      reloadSets
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
    end 
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    tableView.deselectRowAtIndexPath indexPath, animated:YES
    navigationController.pushViewController ModSetController.new(set), animated:YES
  end

  def setEditing(editing, animated:animated)
    super
    tableView.reloadData # force cells to redraw
  end

  ####
  
  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    if alertView.buttonTitleAtIndex(buttonIndex) == "OK"
      setTitle = alertView.textFieldAtIndex(0).text
      ModificationSet.new(setTitle).save
      tableView.reloadData
    end
  end
  
  def textFieldDidEndEditing(textField)
    cell = textField.superview
    index = tableView.indexPathForCell(cell)
    @set = set = @sets[index.row]
    set.renameTo(textField.text)
    textField.text = set.name # name will not be changed if the rename failed
    reloadSets
    tableView.moveRowAtIndexPath index, toIndexPath:Hel.indexPath(set.position, index.section)
  end
  
  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
    true
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
end
