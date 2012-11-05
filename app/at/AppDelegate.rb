class AppDelegate
  attr_accessor :window, :tabBarController, :chartController, :hidesMasterView
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSSetUncaughtExceptionHandler(@exceptionHandler = proc { |exception| applicationDidFailWithException(exception) })

    self.hidesMasterView = NO

    Disk.load
    recoverAfterCrash if NSUserDefaults.standardUserDefaults["crashed"]

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap { |wnd| wnd.backgroundColor = UIColor.whiteColor }

    window.rootViewController = if iphone?
      self.chartController = ChartController.new
      self.tabBarController = UITabBarController.new.tap do |tbc|
        rootController = [chartController, ParametersController.new, CarsController.new, RecentModsController.new, ModSetsController.new]
        tbc.viewControllers = rootController.map do |ctl|
          nav = UINavigationController.alloc.initWithRootViewController(ctl)
          nav.delegate = self
          nav.navigationBar.barStyle = UIBarStyleBlack
          nav.toolbar.barStyle = UIBarStyleBlack
          nav.viewControllers = nav.viewControllers + [IndexedModelsController.new(Model.all)] if CarsController === nav.topViewController
          nav
        end
        tbc.delegate = self
        tbc.selectedIndex = 0
      end
      tabBarController
    else
      self.tabBarController = UITabBarController.new.tap do |tbc|
        rootController = [ParametersController.new, CarsController.new, RecentModsController.new, ModSetsController.new]
        tbc.viewControllers = rootController.map do |ctl|
          nav = UINavigationController.alloc.initWithRootViewController(ctl)
          nav.delegate = self
          nav.navigationBar.barStyle = UIBarStyleBlack
          nav.toolbar.barStyle = UIBarStyleBlack
          nav.viewControllers = nav.viewControllers + [IndexedModelsController.new(Model.all)] if CarsController === nav.topViewController
          nav
        end
        tbc.delegate = self
        tbc.selectedIndex = 0
        tbc.contentSizeForViewInPopover = [320, 640]
      end
      
      self.chartController = ChartController.new
      mainController = UINavigationController.alloc.initWithRootViewController(chartController).tap do |nav|
        nav.delegate = self
        nav.navigationBar.barStyle = UIBarStyleBlack
        nav.toolbar.barStyle = UIBarStyleBlack
      end      

      splitViewController = UISplitViewController.alloc.init
      splitViewController.viewControllers = [tabBarController, mainController]
      splitViewController.delegate = self
      splitViewController
    end

    window.makeKeyAndVisible
    
    # controller = ModelPhotosController.new(Model.modelForKey('bmw--5'), 2012)
    # tabBarController.selectedIndex = 2
    # tabBarController.viewControllers[tabBarController.selectedIndex].pushViewController controller, animated:NO
      
    true
  end
  
  def applicationWillResignActive(application)
    # Sent when the application is about to move from active to inactive state. This can occur for certain types
    # of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application
    # and it begins the transition to the background state.
    # Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. 
    # Games should use this method to pause the game.
  end

  def applicationDidEnterBackground(application)
    # Use this method to release shared resources, save user data, invalidate timers, and store enough application state information
    # to restore your application to its current state in case it is terminated later. 
    # If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  end

  def applicationWillEnterForeground(application)
    # Called as part of the transition from the background to the inactive state; 
    # here you can undo many of the changes made on entering the background.
  end

  def applicationDidBecomeActive(application)
    # Restart any tasks that were paused (or not yet started) while the application was inactive. 
    # If the application was previously in the background, optionally refresh the user interface.
  end

  def applicationWillTerminate(application)
    saveObjectContext
    ES.defaults.synchronize
  end

  def applicationDidFailWithException(exception)
    NSUserDefaults.standardUserDefaults["crashed"] = true
    stack = exception.callStackReturnAddresses
    NSLog "FATAL ERROR: #{exception}"
  end

  ####

  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navController.setToolbarHidden(viewController.toolbarItems.nil?, animated: animated)
  end

  def splitViewController(svc, shouldHideViewController:vc, inOrientation:orientation)
    hidesMasterView # NO # ES.portrait?(orientation)
  end
  
  def splitViewController(svc, willHideViewController:vc, withBarButtonItem:bbi, forPopoverController:pc)
    bbi.title = "Options"
    chartController.navigationItem.setLeftBarButtonItems(chartController.navigationItem.leftBarButtonItems.to_a + [bbi], animated:YES)
  end
  
  def splitViewController(svc, willShowViewController:vc, invalidatingBarButtonItem:bbi)
    chartController.navigationItem.setLeftBarButtonItem(chartController.navigationItem.leftBarButtonItems.to_a - [bbi], animated:YES)
  end

  ####

  def staticContext
    @staticContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = [Mod.entity]

      # storeURL = ES.documentsURL.URLByAppendingPathComponent('db-static.sqlite') # DEV
      storeURL = NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource("db-static", ofType:"sqlite"))
      storeOptions = {NSReadOnlyPersistentStoreOption => YES}
      storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      err = ES.ptr
      storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:storeOptions, error:err)
      raise "Can't open static database: #{err.value.description}" if err.value
      
      context = NSManagedObjectContext.alloc.init
      context.persistentStoreCoordinator = storeCoordinator
      context
    end
  end

  def userContext
    @userContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = [ModSet.entity]

      storeURL = ES.documentsURL.URLByAppendingPathComponent('db-user.sqlite')
      storeOptions = {NSMigratePersistentStoresAutomaticallyOption => YES, NSInferMappingModelAutomaticallyOption => YES}
      storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      err = ES.ptr
      storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:storeOptions, error:err)
      raise "Can't open user database: #{err.value.description}" if err.value

      context = NSManagedObjectContext.alloc.init
      context.persistentStoreCoordinator = storeCoordinator
      context
    end
  end  

  def saveObjectContext(context = userContext)
    context.save(NULL)
  end

  ####
  
  def recoverAfterCrash
    NSLog "Recovering after crash ..."
    Disk.recentMods = Disk.currentMods + Disk.recentMods
    Disk.currentMods = []
    Disk.currentParameters = []
    NSUserDefaults.standardUserDefaults.removeObjectForKey("crashed")
    $lastLaunchDidFail = true    
  end
end
