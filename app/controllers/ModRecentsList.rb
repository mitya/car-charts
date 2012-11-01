class RecentModsController < UITableViewController
  attr_accessor :current, :recent

  def initialize
    self.title = "Recent Models"
    self.tabBarItem = UITabBarItem.alloc.initWithTabBarSystemItem(UITabBarSystemItemRecents, tag:1)
    navigationItem.rightBarButtonItem = ES.textBBI("Save", target:self, action:'saveAsSet')
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
    tableView.reloadData if @reloadPending
    @reloadPending = false
  end
  
  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    @reloadPending = true if object == Disk
  end
  
  ####

  def numberOfSectionsInTableView(tv)
    2
  end

  def tableView(tv, numberOfRowsInSection:section)
    collectionForSection(section).count
  end

  def tableView(tv, titleForHeaderInSection:section)
    case section      
      when 0 then "Selected"
      when 1 then "Recent"
    end
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    mod = modForIndexPath(indexPath)
    modIsSelected = mod.selected?
    cell = tv.dequeueReusableCell(style: UITableViewCellStyleSubtitle)
    cell.textLabel.text = mod.model.name
    cell.detailTextLabel.text = mod.modName
    cell.accessoryType = modIsSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell.textLabel.textColor = modIsSelected ? ES.checkedTableViewItemColor : UIColor.darkTextColor
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)

    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmarkAccessory

    mod = modForIndexPath(indexPath)
    mod.select!
    
    tableView.moveRowAtIndexPath indexPath, toIndexPath:ES.indexPath(indexPath.section == 0 ? 1 : 0, 0)
  end
  
  ####

  def collectionForSection(index)
    collection = index == 0 ? Disk.currentMods : Disk.recentMods
  end

  def modForIndexPath(indexPath)
    collection = collectionForSection(indexPath.section)
    collection[-indexPath.row - 1]
  end
  
  def saveAsSet
    selector = SelectModSetController.new
    selectorNav = UINavigationController.alloc.initWithRootViewController(selector)
    selectorNav.navigationBar.barStyle = UIBarStyleBlack
    if iphone?
      selector.closeProc = -> { dismissModalViewControllerAnimated true, completion:NIL }
      presentViewController selectorNav, animated:YES, completion:NIL
    else            
      selector.closeProc = -> { @popover.dismissPopoverAnimated(YES) }
      @popover = UIPopoverController.alloc.initWithContentViewController(selectorNav)
      @popover.presentPopoverFromBarButtonItem navigationItem.rightBarButtonItem, permittedArrowDirections:UIPopoverArrowDirectionAny, animated:YES
    end
  end
end
