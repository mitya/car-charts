class SelectModSetController < UITableViewController
  attr_accessor :sets, :closeProc

  def initialize
    self.title = "Select Model Set"
    self.contentSizeForViewInPopover = [320, 640]
    navigationItem.rightBarButtonItem = ES.systemBBI(UIBarButtonSystemItemCancel, target:self, action:'cancel')
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
    cell = tv.dequeueReusableCell(klass:DSBadgeViewCell, style:UITableViewCellStyleSubtitle)
    cell.textLabel.text = set.name
    cell.detailTextLabel.text = set.modPreviewString
    cell.badgeText = set.modCount
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    set = @sets[indexPath.row]
    set.mods = Disk.currentMods
    tableView.deselectRowAtIndexPath indexPath, animated:YES
    tableView.cellForRowAtIndexPath(indexPath).toggleCheckmarkAccessory
    closeProc.call
  end

  ####
  
  def reloadSets
    @sets = ModSet.all
  end
  
  def cancel
    closeProc.call
  end
end
