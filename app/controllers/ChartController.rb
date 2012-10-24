class ChartController < UIViewController
  attr_accessor :mods, :params, :comparision, :data, :settingsNavigationController, :tableView, :fsButton, :fsSettingsButton

  def init
    initialize
    self
  end

  def initialize
    self.title = "CarCharts"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Chart", image:UIImage.imageNamed("ico-tbi-chart"), tag:0)
  end

  def viewDidLoad
    @comparision = Comparision.new(Disk.currentMods, Disk.currentParameters)

    # setupTableViewWithStyle(UITableViewStylePlain)

    self.tableView = UITableView.alloc.initWithFrame CGRectMake(0, 0, view.bounds.width, view.bounds.height), style: UITableViewStylePlain
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    tableView.dataSource = tableView.delegate = self
    view.addSubview tableView    

    tableView.rowHeight = 25
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone
    navigationItem.backBarButtonItem = ES.textBBI "Chart"
    
    # segmentedControl = UISegmentedControl.alloc.initWithItems([])
    # segmentedControl.momentary = YES
    # segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
    # segmentedControl.insertSegmentWithImage UIImage.imageNamed("ico-bbi-car"), atIndex:1, animated:NO
    # segmentedControl.insertSegmentWithImage UIImage.imageNamed("ico-bbi-weight"), atIndex:0, animated:NO
    # segmentedControl.addTarget self, action:'settingsSegmentTouched:', forControlEvents:UIControlEventValueChanged
    # navigationItem.rightBarButtonItem = ES.customBBI(segmentedControl)

    fsExpandButton = UIButton.alloc.initWithFrame(CGRectMake(0, 0, 20, 20))
    fsExpandButton.setBackgroundImage UIImage.imageNamed('ico-bbi-fs-expand'), forState:UIControlStateNormal
    fsExpandButton.addTarget self, action:'enterFullScreenMode', forControlEvents:UIControlEventTouchUpInside
    fsExpandButton.showsTouchWhenHighlighted = YES

    navigationItem.rightBarButtonItems = [
      # ES.systemBBI(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),      
      # ES.imageBBI('ico-bbi-fs-expand', style:UIBarButtonItemStyleBordered, target:self, action:'enterFullScreenMode'),
      ES.systemBBI(UIBarButtonSystemItemFixedSpace, target:nil, action:nil).tap { |bbi| bbi.width = 5 },
      ES.customBBI(fsExpandButton),
    ]
    
    # navigationItem.rightBarButtonItems = [
    #   ES.imageBBI('ico-bbi-gears', style:UIBarButtonItemStyleBordered, target:self, action:'showCars'),
    #   ES.imageBBI('ico-bbi-weight', style:UIBarButtonItemStyleBordered, target:self, action:'showParameters')
    # ]
  end

  def viewWillAppear(animated)
    super
    
    @comparision = Comparision.new(Disk.currentMods.sort_by(&:key), Disk.currentParameters)
    tableView.reloadData
    tableView.tableFooterView = ParametersLegendView.new(@comparision.params)

    if @comparision.incomplete?
      view.addSubview(@placeholderView ||= placeholderView)
      tableView.tableFooterView.hidden = true
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
    cell.comparisionItem = comparision.items[ip.row]
    cell
  end
  
  def tableView(tv, heightForRowAtIndexPath:ip)
    item = @comparision.items[ip.row]
    height = 0
    height += BarView::ModelTitleH + BarView::ModelTitleBM
    # height += BarView::ModelTitleH + BarView::ModelTitleBM if item.firstForModel?
    # height += BarView::ModTitleH + BarView::ModTitleBM
    height += @comparision.params.count * BarView::BarFH
    height += 4
    height += 8 if item.lastForModel?
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
      when 1 then showCars
      when 0 then showParameters
    end
  end

  ####

  # def showCars
  #   @settingsTabBarController ||= begin
  #     controllers = [RecentModsController.new, CarsController.new, ModSetsController.new]
  #     controllers.map! { |ctl| UINavigationController.alloc.initWithRootViewController(ctl).tap { |nav| nav.delegate = self } }
  #     controllers.unshift ChartTabStubController.new
  #     controllers[2].viewControllers = controllers[2].viewControllers + [IndexedModelsController.new(Model.all)]
  # 
  #     tabsController = UITabBarController.new
  #     tabsController.delegate = self
  #     tabsController.viewControllers = controllers
  #     tabsController.selectedIndex = 2
  #     tabsController
  #   end
  #   
  #   presentViewController @settingsTabBarController, animated:true, completion:nil      
  # end
  # 
  # def showParameters
  #   @parametersNavigationController ||= begin
  #     parametersCon = ParametersController.new
  #     parametersCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical
  #     parametersNavCon = UINavigationController.alloc.initWithRootViewController(parametersCon)
  #     parametersNavCon.delegate = self
  #     parametersNavCon
  #   end
  #   presentViewController @parametersNavigationController, animated:YES, completion:NIL
  # end
  # 
  # def closeSettings
  #   dismissModalViewControllerAnimated true
  # end
  
  def showSettings
    tabBarController.selectedIndex = 1
  end

  def showFullScreenSettings
    tabBarController.setTabBarHidden(NO, animated:NO)
    tabBarController.selectedIndex = ES.app.previousTabIndex      
  end
  
  def returnFromFullScreenSettings
    tabBarController.setTabBarHidden(YES, animated:YES)
  end

  def toggleFullScreenMode(shouldSwitchOn)
    UIApplication.sharedApplication.setStatusBarHidden(shouldSwitchOn, animated:YES)
    navigationController.setNavigationBarHidden(shouldSwitchOn, animated:YES)
    tabBarController.setTabBarHidden(shouldSwitchOn, animated:YES)
    fsButton.hidden = !shouldSwitchOn
    fsSettingsButton.hidden = !shouldSwitchOn
  end

  def enterFullScreenMode
    toggleFullScreenMode(true)
  end
  
  def exitFullScreenMode
    toggleFullScreenMode(false)
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
  
  def fsButton
    @fsButton ||= UIButton.alloc.initWithFrame(CGRectMake(view.bounds.width - 30 - 5, 5, 30, 30)).tap do |button|
      button.backgroundColor = UIColor.blackColor    
      button.setImage UIImage.imageNamed("ico-bbi-fs-shrink"), forState:UIControlStateNormal
      button.alpha = 0.4
      button.setRoundedCornersWithRadius(3, width:0.5, color:UIColor.grayColor)
      button.showsTouchWhenHighlighted = true
      button.addTarget self, action:'exitFullScreenMode', forControlEvents:UIControlEventTouchUpInside
      view.addSubview(button)
    end    
  end
  
  def fsSettingsButton
    @fsSettingsButton ||= UIButton.alloc.initWithFrame(CGRectMake(view.bounds.width - 30 - 5, view.bounds.height - 35, 30, 30)).tap do |button|
      button.backgroundColor = UIColor.blackColor    
      button.setImage UIImage.imageNamed("ico-bbi-gears"), forState:UIControlStateNormal
      button.alpha = 0.4
      button.setRoundedCornersWithRadius(3, width:0.5, color:UIColor.grayColor)
      button.showsTouchWhenHighlighted = true
      button.addTarget self, action:'showFullScreenSettings', forControlEvents:UIControlEventTouchUpInside
      view.addSubview(button)
    end    
  end
end
