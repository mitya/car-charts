class ModSetSelectionController < UITableViewController
  attr_accessor :sets, :closeProc

  def initialize
    self.title = "Select Model Set"
    self.contentSizeForViewInPopover = [320, 640]
    navigationItem.rightBarButtonItem = ES.systemBBI(UIBarButtonSystemItemCancel, target:self, action:'cancel')
    navigationItem.leftBarButtonItem = ES.systemBBI(UIBarButtonSystemItemAdd, target:self, action:'showNewSetDialog')
  end

  def tableView(tv, numberOfRowsInSection:section)
    reloadSets
    @sets.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    cell = tv.dequeueReusableCell(klass:DSBadgeViewCell, style:UITableViewCellStyleSubtitle)
    cell.textLabel.text = set.name
    cell.detailTextLabel.text = set.modPreviewString
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    set.mods = Disk.currentMods
    tableView.deselectRowAtIndexPath indexPath, animated:YES
    tableView.cellForRowAtIndexPath(indexPath).toggleCheckmarkAccessory
    closeProc.call
  end

  def alertView(alertView, clickedButtonAtIndex:buttonIndex)
    if alertView.buttonTitleAtIndex(buttonIndex) == "OK"
      ModSet.create(name: alertView.textFieldAtIndex(0).text)
      tableView.reloadData
    end
  end    

  ####
  
  def reloadSets
    @sets = ModSet.all
  end
  
  def cancel
    closeProc.call
  end

  def showNewSetDialog
    ModSetsController.showNewSetDialogFor(self)
  end
end
