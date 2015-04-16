class AppDelegate
  include GlobalHelpers
  attr_accessor :window
  attr_accessor :tabBarController, :splitViewContorller, :bannerViewController
  attr_accessor :modelListController, :chartController
  attr_accessor :hidesMasterView
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSSetUncaughtExceptionHandler(@exceptionHandler = proc { |exception| applicationDidFailWithException(exception) })

    self.hidesMasterView = NO

    Disk.load
    recoverAfterCrash if NSUserDefaults.standardUserDefaults["crashed"]

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap { |w| w.backgroundColor = UIColor.whiteColor }
    self.chartController = ChartController.new
    self.modelListController = ModelListController.new
    self.tabBarController = UITabBarController.new.tap do |tbc|
      tabControllers = [chartController, ParameterListController.new, modelListController, ModRecentsController.new, FavoritesController.new]
      tabControllers.shift if KK.ipad?
      tbc.viewControllers = tabControllers.map do |ctr|
        nav = KK.navigationForController(ctr, withDelegate:self)
        nav.navigationBar.translucent = NO
        nav
      end
      tbc.delegate = self
      tbc.tabBar.translucent = NO
    end

    window.rootViewController = if KK.iphone?
      tabBarController.selectedIndex = 0
      tabBarController
    else
      tabBarController.selectedIndex = 1

      chartNavController = KK.navigationForController(chartController, withDelegate:self)
      chartNavController.navigationBar.translucent = NO

      self.splitViewContorller = CustomSplitViewController.alloc.init.tap do |svc|
        svc.viewControllers = [tabBarController, chartNavController]
        svc.delegate = self
      end

      self.bannerViewController = BannerViewController.alloc.initWithContentViewController(splitViewContorller)
    end

    window.makeKeyAndVisible

    setTintColors
    
    Flurry.startSession FLURRY_TOKEN if FLURRY_ENABLED
    
    # openControllerForModel("ford--focus--2014")
    
    true
  end

  def applicationWillTerminate(application)
    saveObjectContext
    KK.defaults.synchronize
  end

  def applicationDidFailWithException(exception)
    NSUserDefaults.standardUserDefaults["crashed"] = true
    stack = exception.callStackReturnAddresses
    
    if FLURRY_ENABLED
      NSLog "Logged error to Flurry"
      Flurry.logError exception.name, message:exception.reason, exception:exception
    end
        
    NSLog "FATAL ERROR: #{exception}"
  end


  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navController.setToolbarHidden(viewController.toolbarItems.nil?, animated: animated)
    KK.trackControllerView(viewController)
  end

  def tabBarController(tabBarController, didSelectViewController: viewController)
    # tabBarController.tabBar.translucent = tabBarController.selectedIndex == 0 if KK.iphone?
  end

  def splitViewController(svc, shouldHideViewController:vc, inOrientation:orientation)
    hidesMasterView
  end

  def splitViewController(svc, willHideViewController:vc, withBarButtonItem:bbi, forPopoverController:pc)
    bbi.title = "Options"
    chartController.navigationItem.setLeftBarButtonItems(chartController.navigationItem.leftBarButtonItems.to_a + [bbi], animated:YES)
  end
  
  def splitViewController(svc, willShowViewController:vc, invalidatingBarButtonItem:bbi)
    chartController.navigationItem.setLeftBarButtonItem(chartController.navigationItem.leftBarButtonItems.to_a - [bbi], animated:YES)
  end
  
  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    # tabBarController.setTabBarHidden KK.landscape?(newOrientation), animated:true if KK.iphone?
  end


  ENCRYPTION = YES

  def staticContext
    @staticContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = [Mod.entity]

      if KK.env?('CCTestModsDataset')
        # debug "Data path: #{KK.documentsPath}"
        # switch mods database to the one located in the documents directory to fill it with the data from plist
        storeURL = KK.documentsURL.URLByAppendingPathComponent('mods.sqlite')
        storeOptions = {}
        NSFileManager.defaultManager.removeItemAtURL(storeURL, error:NULL) if KK.env?('CCTestModsDatasetRun')

      else      

        if NSUserDefaults.standardUserDefaults["firstLaunchTime"] == nil  
          %w(CarCharts.sqlite mods.sqlite mods.sqlite-shm mods.sqlite-wal).each do |filename|
            err = KK.ptr
            srcPath = NSBundle.mainBundle.resourcePath.stringByAppendingPathComponent('db').stringByAppendingPathComponent(filename)
            destPath = KK.documentsPath.stringByAppendingPathComponent(filename)
            NSFileManager.defaultManager.copyItemAtPath srcPath, toPath:destPath, error:err
            NSLog "Can't copy the seed files: #{err.value.description}" if err.value
          end
        end

        if ENCRYPTION
          storeURL = KK.documentsURL.URLByAppendingPathComponent('mods.sqlite')
        end
          storeURL = NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource("db/mods", ofType:"sqlite"))
        end
        storeOptions = {NSReadOnlyPersistentStoreOption => YES}        
      end

      if ENCRYPTION
        storeCoordinator = EncryptedStore.makeStore model, passcode:"a passcode"
      else
        storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      end
            
      err = KK.ptr
      storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:storeOptions, error:err)
      NSLog "Can't open static database: #{err.value.description}" if err.value

      context = NSManagedObjectContext.alloc.init
      context.persistentStoreCoordinator = storeCoordinator
      context
    end
  end

  def userContext
    @userContext ||= begin
      modelClasses = [ModSet]
      model = NSManagedObjectModel.alloc.init
      model.entities = modelClasses.map(&:entity)
      modelClasses.each(&:initRelationships)

      storeURL = KK.documentsURL.URLByAppendingPathComponent('user.sqlite')
      storeOptions = {NSMigratePersistentStoresAutomaticallyOption => YES, NSInferMappingModelAutomaticallyOption => YES}
      storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      err = KK.ptr
      storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:storeOptions, error:err)
      NSLog "Can't open user database: #{err.value.description}" if err.value

      context = NSManagedObjectContext.alloc.init
      context.persistentStoreCoordinator = storeCoordinator
      context
    end
  end

  def saveObjectContext(context = userContext)
    err = KK.ptr
    result = context.save(err)
    if result.is_a?(NSException)
      NSLog "#{result.description}"
    end
    result
  end


  def recoverAfterCrash
    NSLog "Recovering after crash ..."
    resetAllSettings unless KK.env?('CCNoResetAfterCrash')
    NSUserDefaults.standardUserDefaults.removeObjectForKey("crashed")
    $lastLaunchDidFail = true
  end
  
  def resetAllSettings
    Disk.recentMods = []
    Disk.currentMods = []
    Disk.currentParameters = []    
  end

  def setTintColors
    window.tintColor = Configuration.tintColor

    [UINavigationBar, UIToolbar, UISearchBar, UITabBar].each do |bar|
      bar.appearance.barTintColor = Configuration.barTintColor
      bar.appearance.tintColor = Configuration.barIconColor
      bar.appearance.barStyle = UIBarStyleBlack
    end
    
    UISwitch.appearance.onTintColor = Configuration.barIconColor
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent
    UINavigationBar.appearance.setTitleTextAttributes NSForegroundColorAttributeName => Configuration.barTextColor
  end


  def openControllerForModel(modelKey)
    controller = ModListController.new(ModelGeneration.generationForKey(modelKey))
    tabBarController.selectedIndex = 2
    tabBarController.viewControllers[tabBarController.selectedIndex].pushViewController controller, animated:NO
  end
  
  def visibleViewController
    tabBarController.selectedViewController.visibleViewController
  end
  
  def showsBannerAds?
    KK.iphone?
  end
end
