class ChartController < UIViewController
  attr_accessor :mods, :params, :comparision, :data
  attr_accessor :tableView, :exitFullScreenModeButton, :emptyView

  def initialize
    self.title = "CarCharts"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Chart", image:UIImage.imageNamed("ico-tbi-chart"), tag:0)
    navigationItem.backBarButtonItem = ES.textBBI("Chart")

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
    
    navigationItem.rightBarButtonItems = [ ES.fixedSpaceBBIWithWidth(5), toggleFullScreenModeBarItem ]
    
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
      emptyView.removeFromSuperview if @emptyView && @emptyView.superview
      tableView.tableFooterView = ParametersLegendView.new(@comparision.params)
    else
      view.addSubview(emptyView)
      tableView.tableFooterView = nil
    end
  end

  def toggleFullScreenMode
    if iphone?
      shouldSwitchOn = !UIApplication.sharedApplication.isStatusBarHidden
      UIApplication.sharedApplication.setStatusBarHidden(shouldSwitchOn, animated:YES)
      navigationController.setNavigationBarHidden(shouldSwitchOn, animated:YES)
      tabBarController.setTabBarHidden(shouldSwitchOn, animated:YES)
      exitFullScreenModeButton.hidden = !shouldSwitchOn
    else
      ES.app.hidesMasterView = !ES.app.hidesMasterView
      @fullScreen = ES.app.hidesMasterView
      toggleSettingsBarItem.customView.selected = !toggleSettingsBarItem.customView.isSelected
      splitViewController.view.setNeedsLayout
      splitViewController.willRotateToInterfaceOrientation(interfaceOrientation, duration:0)
    end
  end
  
  ####

  def fullScreen?
    @fullScreen
  end

  def emptyView
    @emptyView ||= begin
      text = if $lastLaunchDidFail
        $lastLaunchDidFail = nil
        "Something weird happened.\nModels & parameters were reset.\n\nSorry :("
      else
        "No Models/Parameters Selected"        
      end
      ES.emptyViewLabel(text, view.bounds.rectWithHorizMargins(15))
    end
  end

  def toggleSettingsBarItem
    @toggleSettingsBarItem ||= ES.plainBBI("bbi-back", target:self, action:'toggleFullScreenMode', options:{ 
      selected:"bbi-right", size:[15, 15] 
    })
  end
  
  def toggleFullScreenModeBarItem
    @toggleFullScreenModeBarItem ||= ES.plainBBI("ico-bbi-fs-expand", target:self, action:'toggleFullScreenMode', options:{ 
      size:[20, 20] 
    })
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
end
