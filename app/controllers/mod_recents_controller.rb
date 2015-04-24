class ModRecentsController < UITableViewController
  def initialize
    self.title = "Selected"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("tab-check"), selectedImage:KK.image("tab-check-full"))
    self.navigationItem.titleView = modeSegmentedControl
    Disk.addObserver(self, forKeyPath:"currentMods", options:NO, context:nil)
  end

  def dealloc
    Disk.removeObserver(self, forKeyPath:"currentMods")
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    return if propertyObservingDisabled?(keyPath)
    case keyPath when 'currentMods'
      tableView.reloadData
    end
  end

  def viewDidLoad
    @dataSources = [DataSource.new(self) { Disk.currentMods }, DataSource.new(self) { Disk.sortedRecentMods }]
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
      segm.addTarget self, action:'modeSegmentedControlChanged:', forControlEvents:UIControlEventValueChanged
      segm.selectedSegmentIndex = 0
    end
  end

  def currentDataSource
    dataSourceIndex = modeSegmentedControl.selectedSegmentIndex
    @dataSources[dataSourceIndex]
  end

  def modeSegmentedControlChanged(control)
    KK.trackEvent "selected-recents-switched"
    switchView
  end

  # switches table view data source between Selected & Recent mod lists
  def switchView
    dataSourceIndex = modeSegmentedControl.selectedSegmentIndex
    currentDataSource.reload

    tableView.dataSource = tableView.delegate = currentDataSource
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
    @sheet.addButtonWithTitle "Deselect All"
    # @sheet.addButtonWithTitle "Add Models to Set"
    # @sheet.addButtonWithTitle "Replace Models in Set"
    @sheet.addButtonWithTitle "Cancel"
    @sheet.cancelButtonIndex = 2
    @sheet.showFromBarButtonItem bbi, animated:YES
  end

  def actionSheet(sheet, didDismissWithButtonIndex:buttonIndex)
    actionKey = case buttonIndex
      when 0 then deselectAllMods
      # when 0 then :add
      # when 1 then :replace
    end
    # saveSelectedAsSet(actionKey) if actionKey
  end

  def deselectAllMods
    KK.trackEvent "mods-deselect-all"
    Disk.deselectAllCurrentMods
  end

  def saveSelectedAsSet(mode = :add)
    @selectionController = ModSetSelectionController.new(mode)
    if KK.iphone?
      presentNavigationController @selectionController
    else
      @selectionController.popover = presentPopoverController @selectionController, fromBarItem:navigationItem.rightBarButtonItem
    end
  end

  def screenKey
    { selected: Disk.currentMods.count, recent: Disk.recentMods.count  }
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
        cell.textLabel.adjustsLetterSpacingToFitWidth = YES
      end
      cell.textLabel.text = mod.model.family.name
      cell.detailTextLabel.text = mod.modName(Mod::NameBodyEngineVersionYear)
      cell.toggleLeftCheckmarkAccessory(mod.selected?)
      cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      mod = @mods[indexPath.row]
      controller.withoutObserving('currentMods') { mod.select! }
      tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
      controller.reenableButtons
    end

    def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
      ModViewController.showFor controller, withMod: @mods[indexPath.row]
    end
  end
end
