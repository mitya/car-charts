class ModSetListController < UITableViewController
  attr_accessor :sets

  def initialize
    self.title = "Model Sets"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Sets", image:KK.image("ti-favorites"), selectedImage:KK.image("ti-favoritesFilled"))

    navigationItem.leftBarButtonItem = editButtonItem
    navigationItem.backBarButtonItem = KK.textBBI("Sets")
    navigationItem.rightBarButtonItem = KK.systemBBI(UIBarButtonSystemItemAdd, target:self, action:'showNewSetDialog')

    tableView.rowHeight = ThreeLabelCell.rowHeight
  end

  def viewWillAppear(animated)
    super
    refreshView # update badges
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end


  def tableView(tv, numberOfRowsInSection:section)
    refreshData
    @sets.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    cell = tableView.dequeueReusableCell(klass:ThreeLabelCell, style:UITableViewCellStyleValue1) do |cell|
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      cell.editingAccessoryView = begin
        editingImage = KK.templateImage('ca-edit')
        editingButton = UIButton.buttonWithType(UIButtonTypeCustom)
        editingButton.frame = [[0, 0], [40, ThreeLabelCell.rowHeight]]
        editingButton.setImage editingImage, forState:UIControlStateNormal
        editingButton.addTarget self, action:'editModName:', forControlEvents:UIControlEventTouchUpInside
        editingButton
      end
      cell.hideDetailsWhenEditing = true
    end
    cell.textLabel.text = set.name
    cell.detailTextLabel.text = set.modCount.to_s_or_nil
    cell.commentLabel.text = set.modPreviewString
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
    tableView.deselectRowAtIndexPath indexPath, animated:true
    navigationController.pushViewController ModSetViewController.new(set), animated:YES
  end


  def alertView(alert, clickedButtonAtIndex:buttonIndex)
    if alert.tag == -1 && alert.buttonTitleAtIndex(buttonIndex) == "OK"
      ModSet.create(name: alert.textFieldAtIndex(0).text)
      refreshView
    elsif alert.buttonTitleAtIndex(buttonIndex) == "Save"
      set = @sets[ alert.tag ]
      newName = alert.textFieldAtIndex(0).text
      set.renameTo(newName)

      oldIndexPath = KK.indexPath(0, alert.tag)
      newIndexPath = KK.indexPath(0, set.position)
      tableView.reloadData
      # tableView.moveRowAtIndexPath oldIndexPath, toIndexPath:newIndexPath # can't move and refresh at the same time
    end
  end

  def editModName(button)
    cell = KK.closestSuperviewOfType(UITableViewCell, forView:button)
    indexPath = tableView.indexPathForCell(cell)
    set = @sets[indexPath.row]

    alert = UIAlertView.alloc.initWithTitle("Edit Model Set Title", message:nil, delegate:self, cancelButtonTitle:"Cancel", otherButtonTitles:nil)
    alert.tag = indexPath.row
    alert.alertViewStyle = UIAlertViewStylePlainTextInput
    alert.addButtonWithTitle "Save"
    alert.textFieldAtIndex(0).autocapitalizationType = UITextAutocapitalizationTypeWords
    alert.textFieldAtIndex(0).text = set.name
    alert.show
  end

  def showNewSetDialog
    ModSetListController.showNewSetDialogFor(self)
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
      alertView.tag = -1
      alertView.alertViewStyle = UIAlertViewStylePlainTextInput
      alertView.addButtonWithTitle "OK"
      alertView.textFieldAtIndex(0).autocapitalizationType = UITextAutocapitalizationTypeWords
      alertView.show
    end
  end
end
