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

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  def setEditing(editing, animated:animated)
    super
    refreshView # redraws cells for editing
  end

  ####

  def tableView(tv, numberOfRowsInSection:section)
    refreshData
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
      cell = tv.dequeueReusableCell(klass:DSBadgeViewCell, style:UITableViewCellStyleSubtitle) { |cl| cl.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
      cell.textLabel.text = set.name
      cell.detailTextLabel.text = set.modPreviewString
      cell.badgeText = set.modCount
    end
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

  ####
  
  def textFieldDidEndEditing(textField)
    cell = textField.superview
    index = tableView.indexPathForCell(cell)
    @set = set = @sets[index.row] # save as ivar because of some MM problems
    set.renameTo(textField.text)
    textField.text = set.name # set name is not changed if the rename has failed
    refreshData
    tableView.moveRowAtIndexPath index, toIndexPath:ES.indexPath(index.section, set.position)
  end
  
  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
    true
  end
  
  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    if alertView.buttonTitleAtIndex(buttonIndex) == "OK"
      ModSet.create(name: alertView.textFieldAtIndex(0).text)
      refreshView
    end
  end    
    
  ####

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
