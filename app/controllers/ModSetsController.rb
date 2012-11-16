class ModSetsController < UITableViewController
  attr_accessor :sets

  def initialize
    self.title = "Model Sets"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Sets", image:UIImage.imageNamed("tbi-star3"), tag:5)
    navigationItem.leftBarButtonItem = editButtonItem
    navigationItem.backBarButtonItem = ES.textBBI("Sets")
    navigationItem.rightBarButtonItem = ES.systemBBI(UIBarButtonSystemItemAdd, target:self, action:'showNewSetDialog')
  end

  def viewWillAppear(animated)
    super
    refreshView # update badges
  end

  # def setEditing(editing, animated:animated)
  #   super
  #   refreshView # redraws cells for editing
  # end



  def tableView(tv, numberOfRowsInSection:section)
    refreshData
    @sets.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    cell = tableView.dequeueReusableCell(klass:KKBadgeViewCell, style:UITableViewCellStyleSubtitle) do |cell|
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      cell.textFieldEnabled = true
      cell.textFieldEndEditingBlock = ->(cell) { modSetCellDidEndEditing(cell) }
      cell.textField.placeholder = "Set Title"
    end
    cell.textLabel.text = set.name
    cell.textField.text = set.name
    cell.detailTextLabel.text = set.modPreviewString
    cell.badgeText = set.modCount
    cell
  end

  def tableView(tv, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    case editingStyle when UITableViewCellEditingStyleDelete
      set = @sets[indexPath.row]
      set.delete
      refreshData
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
      self.editing = false if @sets.empty?
    end 
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    tableView.deselectRowAtIndexPath indexPath, animated:YES
    navigationController.pushViewController ModSetController.new(set), animated:YES
  end


  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    if alertView.buttonTitleAtIndex(buttonIndex) == "OK"
      ModSet.create(name: alertView.textFieldAtIndex(0).text)
      refreshView
    end
  end    

  def modSetCellDidEndEditing(cell)
    index = tableView.indexPathForCell(cell)
    @set = @sets[index.row] # save as ivar because after refreshData is called @sets will be different
    @set.renameTo(cell.textField.text.strip)
    cell.textField.text = @set.name # set name is not changed if the rename has failed
    cell.textLabel.text = @set.name
    refreshData
    tableView.moveRowAtIndexPath index, toIndexPath:ES.indexPath(index.section, @set.position)
  end


  def showNewSetDialog
    ModSetsController.showNewSetDialogFor(self)
  end
  
  def refreshData
    @sets = ModSet.all
  end
  
  def refreshView
    tableView.reloadData
    editButtonItem.enabled = @sets.any?
  end


  class << self
    def showNewSetDialogFor(controller)
      alertView = UIAlertView.alloc.initWithTitle("New Model Set",
        message:"Enter the set title", delegate:controller, cancelButtonTitle:"Cancel", otherButtonTitles:nil)
      alertView.alertViewStyle = UIAlertViewStylePlainTextInput
      alertView.addButtonWithTitle "OK"
      alertView.textFieldAtIndex(0).autocapitalizationType = UITextAutocapitalizationTypeWords
      alertView.show
    end        
  end
end