class SelectedModsController < UITableViewController
  def initialize
    self.title = "Selected"
    Disk.addObserver(self, forKeyPath:"currentMods", options:NO, context:nil)
  end
  
  def dealloc
    Disk.removeObserver(self, forKeyPath:"currentMods")
    super
  end
  
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  def viewWillAppear(animated)
    super
    @mods = Disk.currentMods.sort_by(&:key)
    tableView.reloadData if @reloadPending
    @reloadPending = false
  end
  
  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    @reloadPending = true if object == Disk
  end
  
  ###

  def tableView(tableView, numberOfRowsInSection:section)
    @mods.count
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    mod = @mods[indexPath.row]
    modIsSelected = mod.selected?
    cell = tableView.dequeueReusableCell(klass:DSCheckmarkCell, style:UITableViewCellStyleSubtitle) { |cell| cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton }
    cell.textLabel.text = mod.model.name
    cell.detailTextLabel.text = mod.modName(Mod::NameBodyEngineVersion)
    cell.imageView.image = modIsSelected ? UIImage.imageNamed("list_checkmark") : UIImage.imageNamed("list_checkmark_stub")
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)

    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleLeftCheckmarkAccessory(textColor:NO)

    mod = @mods[indexPath.row]
    mod.select!
  end
  
  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
    mod = @mods[indexPath.row]
    navigationController.pushViewController ModController.new(mod), animated:YES
  end    
end
