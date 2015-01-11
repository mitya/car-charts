class ModsControllerForRecent < UITableViewController
  def initialize
    self.title = "Recents"
    self.tabBarItem = UITabBarItem.alloc.initWithTabBarSystemItem(UITabBarSystemItemRecents, tag:3)
    self.navigationItem.titleView = modeSegmentedControl
  end
  
  def viewDidLoad
    @dataSources = [DataSource.new(self) { Disk.currentMods }, DataSource.new(self) { Disk.recentMods }]
  end

  def viewWillAppear(animated)
    super
    switchView
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end  
  
  def modeSegmentedControl
    @modeSegmentedControl ||= UISegmentedControl.alloc.initWithItems(%w(Selected Recents)).tap do |segm|
      segm.segmentedControlStyle = UISegmentedControlStyleBar
      segm.addTarget self, action:'switchView', forControlEvents:UIControlEventValueChanged
      segm.selectedSegmentIndex = 0
    end
  end
  
  # switches table view data source between Selected & Recent mod lists
  def switchView
    dataSourceIndex = modeSegmentedControl.selectedSegmentIndex
    dataSource = @dataSources[dataSourceIndex]
    dataSource.reload
    
    tableView.dataSource = tableView.delegate = dataSource
    tableView.reloadData
    
    navigationItem.setRightBarButtonItem dataSourceIndex == 0 ? actionsButtonItem : nil, animated:NO
    saveButtonItem.enabled = Disk.currentMods.any?
  end


  def actionsButtonItem
    @actionsButtonItem ||= KK.systemBBI(UIBarButtonSystemItemAction, target:self, action:'showActionSheet:')
  end

  def saveButtonItem
    @saveButtonItem ||= KK.textBBI("Save", target:self, action:'saveSelectedAsSet')
  end
  
  def showActionSheet(bbi)
    sheet = UIActionSheet.alloc.initWithTitle(nil, delegate:self, cancelButtonTitle:"Cancel", destructiveButtonTitle:NIL, otherButtonTitles:NIL)
    sheet.addButtonWithTitle "Add to Set"
    sheet.addButtonWithTitle "Replace Set"
    sheet.showFromBarButtonItem bbi, animated:YES
  end
  
  def actionSheet(sheet, clickedButtonAtIndex:buttonIndex)
    case sheet.buttonTitleAtIndex(buttonIndex)
      when "Add to Set" then saveSelectedAsSet(:add)
      when "Replace Set" then saveSelectedAsSet(:replace)
    end
  end
    
  def saveSelectedAsSet(mode = :add)
    selectionCtr = ModSetsControllerForSelection.new
    selectionCtr.mode = mode
    if KK.iphone?
      selectionCtr.closeProc = -> { dismissModalViewControllerAnimated true, completion:NIL }
      presentNavigationController selectionCtr
    else     
      selectionCtr.closeProc = -> { @popover.dismissPopoverAnimated(YES) }
      @popover = presentPopoverController selectionCtr, fromBarItem:navigationItem.rightBarButtonItem
    end
  end
  
  

  class DataSource
    attr_reader :controller
    
    def initialize(controller, &dataLoadingBlock)
      @dataLoadingBlock = dataLoadingBlock
      @controller = controller
    end
    
    def reload
      @mods = @dataLoadingBlock.call.sort_by(&:key)
    end
        
    def tableView(tableView, numberOfRowsInSection:section)
      @mods.count
    end

    def tableView(tableView, cellForRowAtIndexPath:indexPath)
      mod = @mods[indexPath.row]
      cell = tableView.dequeueReusableCell klass:CheckmarkCell, style:UITableViewCellStyleSubtitle, accessoryType:UITableViewCellAccessoryDetailButton
      cell.textLabel.text = mod.model.name
      cell.detailTextLabel.text = mod.modName(Mod::NameBodyEngineVersion)
      cell.toggleLeftCheckmarkAccessory(mod.selected?)
      return cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      tableView.deselectRowAtIndexPath(indexPath, animated:YES)

      cell = tableView.cellForRowAtIndexPath(indexPath)
      cell.toggleLeftCheckmarkAccessory

      mod = @mods[indexPath.row]
      mod.select!
    end
  
    def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
      mod = @mods[indexPath.row]
      controller.navigationController.pushViewController ModController.new(mod), animated:YES
    end    
  end
end
