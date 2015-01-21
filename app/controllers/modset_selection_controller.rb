class ModSetSelectionController < UITableViewController
  attr_accessor :sets, :closeProc, :mode

  def initialize
    self.title = "Select Model Set"
    navigationItem.rightBarButtonItem = KK.systemBBI(UIBarButtonSystemItemCancel, target:self, action:'cancel')
    navigationItem.leftBarButtonItem = KK.systemBBI(UIBarButtonSystemItemAdd, target:self, action:'showNewSetDialog')
    tableView.rowHeight = ThreeLabelCell.rowHeight
    reloadSets
  end

  def preferredContentSize
    [320, (@sets.count) * ThreeLabelCell.rowHeight]
  end

  def tableView(tv, numberOfRowsInSection:section)
    reloadSets
    @sets.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    cell = tv.dequeueReusableCell(klass:ThreeLabelCell, style:UITableViewCellStyleValue1)
    cell.textLabel.text = set.name
    cell.detailTextLabel.text = set.modCount.to_s_or_nil
    cell.commentLabel.text = set.modPreviewString
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    updateSet(set)
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


  def updateSet(set)
    if mode == :replace
      set.mods = Disk.currentMods
    else
      set.mods = set.mods + Disk.currentMods
    end
  end
  
  def reloadSets
    @sets = ModSet.all
  end
  
  def cancel
    closeProc.call
  end

  def showNewSetDialog
    ModSetListController.showNewSetDialogFor(self)
  end
end
