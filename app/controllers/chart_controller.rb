class ChartController < UIViewController
  attr_accessor :mods, :params, :comparision, :data
  attr_accessor :tableView, :exitFullScreenModeButton, :emptyView
  
  def initialize
    self.title = "CarCharts"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Chart", image:KK.image("ti-chart"), tag:1)
    
    self.navigationItem.backBarButtonItem = KK.textBBI("Chart")

    Disk.addObserver(self, forKeyPath:"currentParameters", options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld, context:nil)
    Disk.addObserver(self, forKeyPath:"currentMods", options:NO, context:nil)
  end
  
  def dealloc
    puts 'ChartController.dealloc'
    Disk.removeObserver(self, forKeyPath:"currentParameters")
    Disk.removeObserver(self, forKeyPath:"currentMods")
    super
  end
  
  def viewDidLoad
    self.tableView = setupInnerTableViewWithStyle(UITableViewStylePlain).tap do |tableView|
      tableView.rowHeight = 25
      tableView.separatorStyle = UITableViewCellSeparatorStyleNone
    end
    
    logoImage = KK.image('logo')
    logoImageView = UIImageView.alloc.initWithImage(logoImage)
    navigationItem.titleView = logoImageView
    navigationItem.rightBarButtonItem = toggleFullScreenModeBarItem
    
    @reloadPending = true
  end

  def viewWillAppear(animated)
    super
    reload if @reloadPending
    @reloadPending = false
  end
  
  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration) unless fullScreen?
  end  
                                      
                                        
  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if keyPath == 'currentParameters'
      if removedParam = (change[:old] - change[:new]).first
        removedParamIndex = change[:old].index(removedParam)
        totalParamsLeft = change[:new].count
        ChartBarView.adjustSessionColors(removedParamIndex, totalParamsLeft)
      end
    end
    
    if object == Disk
      if isViewVisible
        reload
      else
        @reloadPending = true
      end
    end
  end

  def didRotateFromInterfaceOrientation(fromInterfaceOrientation)    
    tableView.reloadRowsAtIndexPaths tableView.indexPathsForVisibleRows, withRowAnimation:UITableViewRowAnimationNone
  end


  def tableView(tv, numberOfRowsInSection:section)
    @comparision.complete?? @comparision.mods.count : 0
  end
  
  def tableView(tv, cellForRowAtIndexPath:ip)
    cell = tv.dequeueReusableCell klass:ChartBarView::TableCell, selectionStyle:UITableViewCellSelectionStyleNone
    cell.comparisionItem = @comparision.items[ip.row]
    cell
  end
  
  def tableView(tv, heightForRowAtIndexPath:ip)
    ChartBarView.heightForComparisionItem(@comparision.items[ip.row])
  end


  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navController.setToolbarHidden viewController.toolbarItems.nil?, animated:animated
  end


  def reload
    @comparision = Comparision.new(Disk.currentMods, Disk.currentParameters)
    tableView.reloadData
    
    if KK.ipad?
      tableView.tableHeaderView ||= UIView.alloc.initWithFrame(CGRectMake 0, 0, 100, 10)
    end
    
    if @comparision.complete?
      emptyView.removeFromSuperview if @emptyView && @emptyView.superview
      tableView.tableFooterView = ChartLegendView.new(@comparision.params)
    else
      view.addSubview(emptyView)
      tableView.tableFooterView = nil
    end
  end

  def toggleFullScreenMode
    @fullScreen = !@fullScreen
    if KK.iphone?      
      UIApplication.sharedApplication.setStatusBarHidden(@fullScreen, withAnimation:UIStatusBarAnimationSlide)
      navigationController.setNavigationBarHidden(@fullScreen, animated:YES)
      tabBarController.setTabBarHidden(@fullScreen || KK.landscape?, animated:YES)
      exitFullScreenModeButton.hidden = !@fullScreen
    else
      KK.app.delegate.hidesMasterView = @fullScreen
      splitViewController.view.setNeedsLayout
      splitViewController.willRotateToInterfaceOrientation(interfaceOrientation, duration:0)
    end
  end

  def prefersStatusBarHidden
    fullScreen? || super
  end

  def fullScreen?
    @fullScreen
  end

  def emptyView
    @emptyView ||= begin
      text = if $lastLaunchDidFail
        $lastLaunchDidFail = nil
        "Something weird happened\nModels & parameters were reset\n\nSorry :("
      else
        "No Models/Parameters Selected"        
      end
      KK.emptyViewLabel(text, view.bounds.rectWithHorizMargins(15))
    end
  end

  def toggleFullScreenModeBarItem
    @toggleFullScreenModeBarItem ||= KK.imageBBI("bi-fullScreenEnter", target:self, action:'toggleFullScreenMode')
  end
    
  def exitFullScreenModeButton
    # button frame with respect to orientation = view.bounds.width - 52, KK.landscape?? 6 : 26, 30, 30
    @exitFullScreenModeButton ||= UIButton.alloc.initWithFrame(CGRectMake(view.bounds.width - 52, 22, 30, 30)).tap do |button|
      button.backgroundColor = UIColor.blackColor    
      button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
      button.setImage KK.templateImage("bi-fullScreenExit"), forState:UIControlStateNormal
      button.tintColor = :white.uicolor
      button.alpha = 0.5
      button.setRoundedCornersWithRadius(3, width:0.5, color:UIColor.grayColor)
      button.addTarget self, action:'toggleFullScreenMode', forControlEvents:UIControlEventTouchUpInside
      view.addSubview(button)
    end    
  end    
end
