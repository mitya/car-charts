class AppDelegate
  attr_accessor :window, :tabBarController, :chartController, :hidesMasterView
  attr_accessor :modelListController
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSSetUncaughtExceptionHandler(@exceptionHandler = proc { |exception| applicationDidFailWithException(exception) })

    self.hidesMasterView = NO

    Disk.load
    recoverAfterCrash if NSUserDefaults.standardUserDefaults["crashed"]

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap { |w| w.backgroundColor = UIColor.whiteColor }
    self.chartController = ChartController.new
    self.modelListController = ModelListController.new
    self.tabBarController = UITabBarController.new.tap do |tbc|
      tabControllers = [chartController, ParameterListController.new, modelListController, ModRecentsController.new, ModSetListController.new]
      tabControllers.shift if KK.ipad?
      tbc.viewControllers = tabControllers.map do |ctr|
        nav = KK.navigationForController(ctr, withDelegate:self)
        # nav.navigationBar.translucent = NO
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
      mainController = KK.navigationForController(chartController, withDelegate:self)
      CustomSplitViewController.alloc.init.tap do |splitViewController|
        splitViewController.viewControllers = [tabBarController, mainController]
        splitViewController.delegate = self
      end
    end

    window.makeKeyAndVisible

    setTintColors
    
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
    NSLog "FATAL ERROR: #{exception}"
  end


  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navController.setToolbarHidden(viewController.toolbarItems.nil?, animated: animated)
  end

  def tabBarController(tabBarController, didSelectViewController: viewController)
    if :useTranslucentTabOnlyForChart == true
      return if KK.ipad?
      tabBarController.tabBar.translucent = tabBarController.selectedIndex == 0 && KK.iphone?
    end
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
    if :hideTabBarOnRotation == true
      return unless KK.iphone?
      tabBarController.setTabBarHidden KK.landscape?(newOrientation), animated:true
    end
  end


  def staticContext
    @staticContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = [Mod.entity]

      if KK.env?('CCTestModsDataset')
        NSLog "Data path: #{KK.documentsURL}"
        # switch mods database to the one located in the documents directory to fill it with the data from plist
        storeURL = KK.documentsURL.URLByAppendingPathComponent('mods.sqlite')
        storeOptions = {}
        NSFileManager.defaultManager.removeItemAtURL(storeURL, error:NULL) if KK.env?('CCTestModsDatasetRun')
      else
        storeURL = NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource("db/mods", ofType:"sqlite"))
        storeOptions = {NSReadOnlyPersistentStoreOption => YES}        
      end

      storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
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
end
