class ChartController < UIViewController
  attr_accessor :mods, :params, :comparision, :data
  attr_accessor :tableView, :enterFullScreenModeBBI, :exitFullScreenModeButton, :placeholderView

  def initialize
    self.title = "CarCharts"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Chart", image:UIImage.imageNamed("ico-tbi-chart"), tag:0)
    navigationItem.backBarButtonItem = ES.textBBI("Chart")
    navigationItem.leftBarButtonItem = ES.plainBBI("bbi-back", target:self, action:'hideSettings', options:{
      selected:"bbi-right", size:[15, 15]
    })

    Disk.addObserver(self, forKeyPath:"currentParameters", options:NO, context:nil)
    Disk.addObserver(self, forKeyPath:"currentMods", options:NO, context:nil)
  end
  
  def dealloc
    Disk.removeObserver(self, forKeyPath:"currentParameters")
    Disk.removeObserver(self, forKeyPath:"currentMods")    
    super
  end

  def viewDidLoad
    self.tableView = setupTableViewWithStyle(UITableViewStylePlain).tap do |tableView|
      tableView.rowHeight = 25
      tableView.separatorStyle = UITableViewCellSeparatorStyleNone      
    end
    
    if iphone?
      self.enterFullScreenModeBBI = ES.plainBBI("ico-bbi-fs-expand", target:self, action:'toggleFullScreenMode', options:{ size:[20, 20] })
      navigationItem.rightBarButtonItems = [
        ES.systemBBI(UIBarButtonSystemItemFixedSpace, target:nil, action:nil).tap { |bbi| bbi.width = 5 },
        enterFullScreenModeBBI
      ]
    end
    
    @reloadPending = true
  end

  def viewWillAppear(animated)
    super
    reload if @reloadPending
    @reloadPending = false
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    isViewVisible ? reload : (@reloadPending = true ) if object == Disk
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
    @comparision.complete?? @comparision.mods.count : 0
  end
  
  def tableView(tv, cellForRowAtIndexPath:ip)
    cell = tv.dequeueReusableCell(klass:BarView::TableCell) { |c| c.selectionStyle = UITableViewCellSelectionStyleNone }
    cell.comparisionItem = comparision.items[ip.row]
    cell
  end
  
  def tableView(tv, heightForRowAtIndexPath:ip)
    BarView.heightForComparisionItem(@comparision.items[ip.row])
  end

  ####

  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navController.setToolbarHidden viewController.toolbarItems.nil?, animated:animated
  end
  
  ####

  def reload
    @comparision = Comparision.new(Disk.currentMods.sort_by(&:key), Disk.currentParameters)
    tableView.reloadData
    
    if @comparision.complete?
      placeholderView.removeFromSuperview if @placeholderView && @placeholderView.superview
      tableView.tableFooterView = ParametersLegendView.new(@comparision.params)
    else
      view.addSubview(placeholderView)
      tableView.tableFooterView = nil
    end
  end

  def toggleFullScreenMode
    shouldSwitchOn = !UIApplication.sharedApplication.isStatusBarHidden
    
    UIApplication.sharedApplication.setStatusBarHidden(shouldSwitchOn, animated:YES)
    navigationController.setNavigationBarHidden(shouldSwitchOn, animated:YES)
    tabBarController.setTabBarHidden(shouldSwitchOn, animated:YES)
    exitFullScreenModeButton.hidden = !shouldSwitchOn
  end

  def placeholderView
    @placeholderView ||= begin
      text = if $lastLaunchDidFail
        $lastLaunchDidFail = nil
        "Something weird happened, the parameters and models were reset. Sorry :("
      else
        "Select some cars and parameters to compare"
      end
      ES.tableViewPlaceholder(text, view.bounds.rectWithHorizMargins(15))
    end
  end
  
  def exitFullScreenModeButton
    @exitFullScreenModeButton ||= UIButton.alloc.initWithFrame(CGRectMake(view.bounds.width - 35, 5, 30, 30)).tap do |button|
      button.backgroundColor = UIColor.blackColor    
      button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
      button.setImage UIImage.imageNamed("ico-bbi-fs-shrink"), forState:UIControlStateNormal
      button.alpha = 0.3
      button.setRoundedCornersWithRadius(3, width:0.5, color:UIColor.grayColor)
      button.showsTouchWhenHighlighted = true
      button.addTarget self, action:'toggleFullScreenMode', forControlEvents:UIControlEventTouchUpInside
      view.addSubview(button)
    end    
  end  
  
  def hideSettings
    ES.app.hidesMasterView = !ES.app.hidesMasterView
    @fullScreen = ES.app.hidesMasterView
    navigationItem.leftBarButtonItem.customView.selected = !navigationItem.leftBarButtonItem.customView.isSelected
    splitViewController.view.setNeedsLayout
    splitViewController.willRotateToInterfaceOrientation(interfaceOrientation, duration:0)
  end
  
  def fullScreen?
    @fullScreen
  end
end
