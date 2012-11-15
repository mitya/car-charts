class RecentModsController < UITableViewController
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


  
  def modeSegmentedControl
    @modeSegmentedControl ||= UISegmentedControl.alloc.initWithItems(%w(Selected Recents)).tap do |segm|
      segm.segmentedControlStyle = UISegmentedControlStyleBar
      segm.addTarget self, action:'switchView', forControlEvents:UIControlEventValueChanged
      segm.selectedSegmentIndex = 0
    end
  end
  
  def switchView
    dataSourceIndex = modeSegmentedControl.selectedSegmentIndex
    dataSource = @dataSources[dataSourceIndex]
    dataSource.reload
    tableView.dataSource = tableView.delegate = dataSource
    tableView.reloadData
    
    navigationItem.setRightBarButtonItem dataSourceIndex == 0 ? saveButtonItem : nil, animated:NO
    saveButtonItem.enabled = Disk.currentMods.any?
  end

  ###

  def saveButtonItem
    @saveButtonItem ||= ES.textBBI("Save", target:self, action:'saveAsSet')
  end
  
  def saveAsSet
    selectionCtr = ModSetSelectionController.new
    if iphone?
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
      modIsSelected = mod.selected?
      tableView.reusableCellWith(klass:DSCheckmarkCell, style:UITableViewCellStyleSubtitle) do |cell|
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton
        cell.textLabel.text = mod.model.name
        cell.detailTextLabel.text = mod.modName(Mod::NameBodyEngineVersion)
        cell.imageView.image = modIsSelected ? UIImage.imageNamed("list_checkmark") : UIImage.imageNamed("list_checkmark_stub")
      end
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
      controller.navigationController.pushViewController ModController.new(mod), animated:YES
    end    
  end
end
