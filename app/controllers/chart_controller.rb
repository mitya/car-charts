class ChartController < UIViewController
  attr_accessor :mods, :params, :comparision, :data
  attr_accessor :tableView, :exitFullScreenModeButton, :emptyView, :adView

  def initialize
    self.title = "Chart"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("tab-chart"), selectedImage:KK.image("tab-chart-full"))
    self.navigationItem.backBarButtonItem = KK.textBBI("Chart")
    self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyManual    

    Disk.addObserver(self, forKeyPath:"currentParameters", options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld, context:nil)
    Disk.addObserver(self, forKeyPath:"currentMods", options:NO, context:nil)
    Disk.addObserver(self, forKeyPath:"unitSystem", options:NO, context:nil)
    
    @reloadCount = 0
  end

  def dealloc
    KK.debug 'ChartController.dealloc'
    Disk.removeObserver(self, forKeyPath:"currentParameters")
    Disk.removeObserver(self, forKeyPath:"currentMods")
    Disk.removeObserver(self, forKeyPath:"unitSystem")
    super
  end

  def viewDidLoad
    # if KK.iphone?
    #   self.adView = ADBannerView.alloc.initWithAdType ADAdTypeBanner
    #   adView.backgroundColor = UIColor.clearColor
    #   adView.delegate = self
    #   view.addSubview adView
    # end
      
    self.tableView = setupInnerTableViewWithStyle(UITableViewStylePlain)
    tableView.rowHeight = 25
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone
    tableView.autoresizingMask = adView ? UIViewAutoresizingFlexibleWidth : UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    
    navigationItem.titleView = UIImageView.alloc.initWithImage(KK.image('logo'))  
    navigationItem.rightBarButtonItem = toggleFullScreenModeBarItem

    @reloadPending = true
  end

  def viewWillAppear(animated) super
    reload if @reloadPending
    reflowViews
  end
  
  def viewDidAppear(animated) super
    tryToShowFullScreenAd if KK.iphone? && @reloadCount > showAdAfter 
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    case keyPath when 'currentParameters'
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

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration) unless fullScreen?
    reflowViews(newOrientation, duration)
  end

  def didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    tableView.reloadRowsAtIndexPaths tableView.indexPathsForVisibleRows, withRowAnimation:UITableViewRowAnimationNone
  end


  def tableView(tv, numberOfRowsInSection:section)
    @comparision.complete?? @comparision.mods.count : 0
  end

  def tableView(tv, cellForRowAtIndexPath:ip)
    cell = tv.dequeueReusableCell klass:ChartBarView::TableCell
    cell.comparisionItem = @comparision.items[ip.row]
    cell
  end

  def tableView(tv, heightForRowAtIndexPath:ip)
    ChartBarView.heightForComparisionItem(@comparision.items[ip.row])
  end

  def tableView(tv, didSelectRowAtIndexPath:ip)
    tableView.deselectRowAtIndexPath(ip, animated:true)
    
    return if fullScreen?

    mod = comparision.mods[ip.row]
    modListController = ModListController.new(mod.generation)
    modListController.selectedMod = mod
    
    modelsNavController = KK.app.delegate.modelListController.navigationController
    KK.app.delegate.tabBarController.selectedViewController = modelsNavController
    modelsNavController.popToRootViewControllerAnimated(NO)
    modelsNavController.pushViewController modListController, animated:NO
  end

  def tableView(tv, commitEditingStyle:editingStyle, forRowAtIndexPath:ip)
    case editingStyle when UITableViewCellEditingStyleDelete
      mod = comparision.mods[ip.row]
      if comparision.containsOnlyBodyParams?
        sameModelMods = comparision.allMods.select { |m| m.generation == mod.generation }
        Disk.removeModsFromCurrent(sameModelMods)
      else        
        Disk.removeModsFromCurrent(mod)
      end
      # tableView.deleteRowsAtIndexPaths([ip], withRowAnimation:UITableViewRowAnimationFade)
    end
  end

  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navController.setToolbarHidden viewController.toolbarItems.nil?, animated:animated
  end


  def prefersStatusBarHidden
    fullScreen? || super
  end

  def fullScreen?
    @fullScreen
  end

  def newEmptyView
    text = if $lastLaunchDidFail
      $lastLaunchDidFail = nil
      "Something weird has happened\nComparision parameters were reset"
    elsif Disk.currentParameters.none? && Disk.currentMods.none?
      "No Models & Parameters Selected"
    elsif Disk.currentParameters.none?
      "No Parameters Selected"
    elsif Disk.currentMods.none?        
      "No Models Selected"
    end
    @emptyView = KK.emptyViewLabel(text, view.bounds.rectWithHorizMargins(15))
  end

  def toggleFullScreenModeBarItem
    @toggleFullScreenModeBarItem ||= KK.imageBBI("bi-fullScreenEnter", target:self, action:'toggleFullScreenMode')
  end

  def exitFullScreenModeButton
    @exitFullScreenModeButton ||= begin
      button = UIButton.alloc.initWithFrame(CGRectMake(view.bounds.width - 50, 20, 40, 40))
      button.backgroundColor = UIColor.blackColor
      button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
      button.setImage KK.templateImage("bi-fullScreenExit"), forState:UIControlStateNormal
      button.tintColor = :white.uicolor
      button.alpha = 0.5
      button.setRoundedCornersWithRadius(3, width:0.5, color:UIColor.grayColor)
      button.addTarget self, action:'toggleFullScreenMode', forControlEvents:UIControlEventTouchUpInside
      view.addSubview(button)
      button
    end
  end


  def reload(reloadView = true)  
    @reloadPending = false
    @comparision = Comparision.new(Disk.currentMods, Disk.currentParameters)
    @reloadCount += 1
    
    # KK.trackEvent "comparision-update", mods_count: @comparision.mods.count, params_count: comparision.params.count
    
    tableView.reloadData if reloadView

    if KK.ipad?
      tableView.tableHeaderView ||= UIView.alloc.initWithFrame(CGRectMake 0, 0, 100, 10)
    end

    @emptyView.removeFromSuperview if @emptyView
    if @comparision.complete?      
      tableView.tableFooterView = ChartLegendView.new(@comparision.params)
    else
      view.addSubview(newEmptyView)
      tableView.tableFooterView = nil
    end
    
    tryToShowFullScreenAd if @reloadCount > showAdAfter if KK.ipad?

    # clearScreenToMakeLaunchImage
  end

  def toggleFullScreenMode
    @fullScreen = !@fullScreen

    KK.trackEvent "full-screen-mode-on", selected: Disk.currentMods.count if @fullScreen

    if KK.iphone?
      UIApplication.sharedApplication.setStatusBarHidden(@fullScreen, withAnimation:UIStatusBarAnimationSlide)
      navigationController.setNavigationBarHidden(@fullScreen, animated:YES)
      tabBarController.setTabBarHidden(@fullScreen, animated:YES)
      exitFullScreenModeButton.hidden = !@fullScreen
    else
      KK.app.delegate.hidesMasterView = @fullScreen
      splitViewController.view.setNeedsLayout
      splitViewController.willRotateToInterfaceOrientation(interfaceOrientation, duration:0)
    end
    
    reflowViews
  end

  def clearScreenToMakeLaunchImage
    @comparision = Comparision.new([], [])
    emptyView.removeFromSuperview if @emptyView && @emptyView.superview
    tableView.tableFooterView = nil
    tableView.reloadData

    # make screenshots, place them into resources dir, and run rake g:chop
  end
  
  def reflowViews(interfaceOrientation = UIApplication.sharedApplication.statusBarOrientation, duration = 0)    
    # if KK.iphone?
    #   tabBarH = tabBarController.tabBar.frame.size.height
    #   navigationBarH = navigationController.navigationBar.frame.size.height
    #
    #   if adView
    #     adView.currentContentSizeIdentifier = KK.landscape?(interfaceOrientation) ? ADBannerContentSizeIdentifier480x32 : ADBannerContentSizeIdentifier320x50
    #
    #     viewH = KK.screenH - case
    #       when fullScreen? then 0
    #       when KK.landscape?(interfaceOrientation) then navigationBarH + tabBarH
    #       else KK.statusBarH + navigationBarH + tabBarH
    #     end
    #     adViewH = KK.landscape?(interfaceOrientation) ? 32 : 50
    #     tableViewHeight = viewH - adViewH
    #
    #     adView.frame = adView.frame.change(y: tableViewHeight)
    #     tableView.frame = tableView.frame.change(y: 0, height: tableViewHeight)
    #   else
    #     viewH = KK.screenH - case
    #       when fullScreen? then 0
    #       when KK.landscape?(interfaceOrientation) then navigationBarH + tabBarH
    #       else KK.statusBarH + navigationBarH + tabBarH
    #     end
    #     tableView.frame = tableView.frame.change(y: 0, height: viewH)
    #   end
    # end
  end
  
  def tryToShowFullScreenAd
    willShowAd = requestInterstitialAdPresentation
    @reloadCount = 0 if willShowAd
  end
  
  def showAdAfter
    KK.iphone?? SHOW_AD_CHART_VIEW_IPHONE : SHOW_AD_CHART_VIEW_IPAD
  end
end
