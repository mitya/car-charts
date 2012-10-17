class ChartController < UITableViewController
  attr_accessor :mods, :params, :comparision, :data, :settingsNavigationController

  def viewDidLoad
    @comparision = Comparision.new(Disk.currentMods, Disk.currentParameters)

    self.title = "CarCharts"

    tableView.backgroundColor = ES.pattern("bg-chart")
    tableView.rowHeight = 25
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone
    tableView.tableFooterView = ParametersLegendView.new(@comparision.params)

    navigationItem.backBarButtonItem = ES.textBBI "Chart"

    segmentedControl = UISegmentedControl.alloc.initWithItems([])
    segmentedControl.momentary = YES
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
    segmentedControl.insertSegmentWithImage UIImage.imageNamed("ico-bbi-car"), atIndex:0, animated:NO
    segmentedControl.insertSegmentWithImage UIImage.imageNamed("ico-bbi-weight"), atIndex:1, animated:NO
    segmentedControl.addTarget self, action:'settingsSegmentTouched:', forControlEvents:UIControlEventValueChanged
    navigationItem.rightBarButtonItem = ES.customBBI(segmentedControl)
  end

  def viewWillAppear(animated)
    super
    
    @comparision = Comparision.new(Disk.currentMods.sort_by(&:key), Disk.currentParameters)
    tableView.reloadData
    tableView.tableFooterView.parameters = @comparision.params
    tableView.tableFooterView.hidden = @comparision.incomplete?

    if @comparision.incomplete?
      view.addSubview(@placeholderView ||= placeholderView)
    else
      @placeholderView.removeFromSuperview if @placeholderView && @placeholderView.superview
    end
  end

  ####
  
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  def didRotateFromInterfaceOrientation(fromInterfaceOrientation)    
    tableView.reloadRowsAtIndexPaths tableView.indexPathsForVisibleRows, withRowAnimation:UITableViewRowAnimationNone
  end

  ####

  def tableView(tv, numberOfRowsInSection:section)
    @comparision.mods.count
  end
  
  def tableView(tv, cellForRowAtIndexPath:ip)
    cell = tv.dequeueReusableCell(klass:BarTableViewCell) { |cl| cl.selectionStyle = UITableViewCellSelectionStyleNone }
    cell.item = comparision.items[ip.row]
    cell
  end
  
  def tableView(tv, heightForRowAtIndexPath:ip)
    item = comparision.items[ip.row]
    height = BarView::BarDetailHeight
    height += BarView::BarTitleHeight if item.first?
    height += 2 if item.last?
    height += (comparision.params.count - 1) * BarView::BarFullHeight
    height += 4
    height
  end

  ####

  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navController.setToolbarHidden viewController.toolbarItems.nil?, animated:animated
  end

  def tabBarController(tabBarController, shouldSelectViewController:viewController)
    if viewController.is_a?(ChartTabStubController)
      closeSettings
      false
    else
      true
    end
  end

  def settingsSegmentTouched(segmentControl)
    case segmentControl.selectedSegmentIndex
    when 0 then showCars
    when 1 then showParameters
    end
  end

  ####

  def showCars
    # @carsNavigationController ||= begin
    #   carsCon = CarsController.new
    #   carsCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical
    #   carsNavCon = UINavigationController.alloc.initWithRootViewController(carsCon)
    #   carsNavCon.delegate = self  
    #   carsNavCon
    # end
    # presentViewController @carsNavigationController, animated:YES, completion:NIL

    @settingsTabBarController ||= begin
      controllers = [RecentModsController.new, IndexedModelsController.new(Model.all), CategoriesController.new, ModSetsController.new]
      controllers.map! { |ctl| UINavigationController.alloc.initWithRootViewController(ctl).tap { |nav| nav.delegate = self } }
      controllers.unshift ChartTabStubController.new

      tabsController = UITabBarController.new
      tabsController.delegate = self
      tabsController.viewControllers = controllers
      tabsController.selectedIndex = 2
      tabsController
    end
    
    presentViewController @settingsTabBarController, animated:true, completion:nil      
  end

  def showParameters
    @parametersNavigationController ||= begin
      parametersCon = ParametersController.new
      parametersCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical
      parametersNavCon = UINavigationController.alloc.initWithRootViewController(parametersCon)
      parametersNavCon.delegate = self
      parametersNavCon
    end
    presentViewController @parametersNavigationController, animated:YES, completion:NIL
  end

  def closeSettings
    dismissModalViewControllerAnimated true
  end

  ####

  def placeholderView
    text = if $lastLaunchDidFail
      $lastLaunchDidFail = nil
      "Something weird happened, the parameters and models were reset. Sorry :("
    else
      "Select some cars and parameters to compare"
    end
    ES.tableViewPlaceholder(text, view.bounds.rectWithHorizMargins(15))
  end
end

class ChartTabStubController < UITableViewController  
  def initialize
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Chart", image:UIImage.imageNamed("ico-tbi-car"), tag:0)
  end
end
