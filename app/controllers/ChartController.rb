class ChartController < UIViewController
  attr_accessor :mods, :params, :comparision, :data, :settingsNavigationController, :tableView, :exitFullScreenModeButton, :fsSettingsButton

  def initialize
    self.title = "CarCharts"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Chart", image:UIImage.imageNamed("ico-tbi-chart"), tag:0)
  end

  def viewDidLoad
    @comparision = Comparision.new(Disk.currentMods, Disk.currentParameters)

    self.tableView = setupTableViewWithStyle(UITableViewStylePlain).tap do |tableView|
      tableView.rowHeight = 25
      tableView.separatorStyle = UITableViewCellSeparatorStyleNone      
    end
    
    enterFullScreenModeButton = UIButton.alloc.initWithFrame(CGRectMake(0, 0, 20, 20)).tap do |button|
      button.setBackgroundImage UIImage.imageNamed('ico-bbi-fs-expand'), forState:UIControlStateNormal
      button.addTarget self, action:'toggleFullScreenMode', forControlEvents:UIControlEventTouchUpInside
      button.showsTouchWhenHighlighted = YES      
    end

    navigationItem.backBarButtonItem = ES.textBBI "Chart"
    navigationItem.rightBarButtonItems = [
      ES.systemBBI(UIBarButtonSystemItemFixedSpace, target:nil, action:nil).tap { |bbi| bbi.width = 5 },
      ES.customBBI(enterFullScreenModeButton),
    ]
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

  ####

  def toggleFullScreenMode
    shouldSwitchOn = !UIApplication.sharedApplication.isStatusBarHidden
    
    UIApplication.sharedApplication.setStatusBarHidden(shouldSwitchOn, animated:YES)
    navigationController.setNavigationBarHidden(shouldSwitchOn, animated:YES)
    tabBarController.setTabBarHidden(shouldSwitchOn, animated:YES)
    exitFullScreenModeButton.hidden = !shouldSwitchOn
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
  
  def exitFullScreenModeButton
    @exitFullScreenModeButton ||= UIButton.alloc.initWithFrame(CGRectMake(view.bounds.width - 30 - 5, 5, 30, 30)).tap do |button|
      button.backgroundColor = UIColor.blackColor    
      button.setImage UIImage.imageNamed("ico-bbi-fs-shrink"), forState:UIControlStateNormal
      button.alpha = 0.3
      button.setRoundedCornersWithRadius(3, width:0.5, color:UIColor.grayColor)
      button.showsTouchWhenHighlighted = true
      button.addTarget self, action:'toggleFullScreenMode', forControlEvents:UIControlEventTouchUpInside
      view.addSubview(button)
    end    
  end  
end
