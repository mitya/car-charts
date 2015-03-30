class ModRecentsController < UITableViewController
  def initialize
    self.title = "Selected"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("ti-selected"), tag:3)
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
  
  def switchView
    # switches table view data source between Selected & Recent mod lists
    
    dataSourceIndex = modeSegmentedControl.selectedSegmentIndex
    dataSource = @dataSources[dataSourceIndex]
    dataSource.reload
    
    tableView.dataSource = tableView.delegate = dataSource
    tableView.reloadData
    
    navigationItem.setRightBarButtonItem dataSourceIndex == 0 ? actionsButtonItem : nil, animated:true
    
    reenableButtons
  end


  def reenableButtons
    actionsButtonItem.enabled = Disk.currentMods.any?
  end

  def actionsButtonItem
    @actionsButtonItem ||= KK.systemBBI(UIBarButtonSystemItemAction, target:self, action:'showActionSheet:')
  end
  
  def showActionSheet(bbi)
    @sheet = UIActionSheet.alloc.initWithTitle nil, delegate:self, cancelButtonTitle:nil, destructiveButtonTitle:NIL, otherButtonTitles:NIL
    @sheet.addButtonWithTitle "Add Models to Set"
    @sheet.addButtonWithTitle "Replace Models in Set"
    @sheet.addButtonWithTitle "Cancel"
    @sheet.cancelButtonIndex = 2
    @sheet.showFromBarButtonItem bbi, animated:YES
  end
  
  def actionSheet(sheet, didDismissWithButtonIndex:buttonIndex)
    actionKey = case buttonIndex
      when 0 then :add
      when 1 then :replace
    end
    saveSelectedAsSet(actionKey) if actionKey
  end
    
  def saveSelectedAsSet(mode = :add)
    @selectionController = ModSetSelectionController.new(mode)
    if KK.iphone?
      presentNavigationController @selectionController
    else
      @selectionController.popover = presentPopoverController @selectionController, fromBarItem:navigationItem.rightBarButtonItem
    end
  end
    

  class DataSource
    attr_reader :controller
    
    def initialize(controller, &dataLoadingBlock)
      @dataLoadingBlock = dataLoadingBlock
      @controller = controller
    end
    
    def reload
      @mods = @dataLoadingBlock.call
    end
        
    def tableView(tableView, numberOfRowsInSection:section)
      @mods.count
    end

    def tableView(tableView, cellForRowAtIndexPath:indexPath)
      mod = @mods[indexPath.row]
      cell = tableView.dequeueReusableCell klass:CheckmarkCell, style:UITableViewCellStyleSubtitle, accessoryType:UITableViewCellAccessoryDetailButton do |cell|
        cell.textLabel.adjustsFontSizeToFitWidth = YES
        # cell.textLabel.minimumScaleFactor = 0.5
      end
      cell.textLabel.text = mod.model.name
      cell.detailTextLabel.text = mod.modName(Mod::NameBodyEngineVersionYear)
      cell.toggleLeftCheckmarkAccessory(mod.selected?)
      return cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      tableView.deselectRowAtIndexPath(indexPath, animated:YES)

      cell = tableView.cellForRowAtIndexPath(indexPath)
      cell.toggleLeftCheckmarkAccessory

      mod = @mods[indexPath.row]
      mod.select!
      
      controller.reenableButtons
    end
  
    def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
      ModViewController.showFor controller, withMod: @mods[indexPath.row]
    end    
  end
end
