class AppDelegate
  attr_accessor :window, :tabBarController, :chartController, :hidesMasterView
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSSetUncaughtExceptionHandler(@exceptionHandler = proc { |exception| applicationDidFailWithException(exception) })

    self.hidesMasterView = NO

    Disk.load
    recoverAfterCrash if NSUserDefaults.standardUserDefaults["crashed"]

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap { |w| w.backgroundColor = UIColor.whiteColor }

    setTintColors

    self.chartController = ChartController.new
    self.tabBarController = UITabBarController.new.tap do |tbc|
      tabControllers = [chartController, ParametersController.new, ModelsController.new, ModsControllerForRecent.new, ModSetsController.new]
      tabControllers.shift if KK.ipad?
      tbc.viewControllers = tabControllers.map { |ctr| nav = KK.navigationForController(ctr, withDelegate:self) }
      tbc.delegate = self
      tbc.selectedIndex = 0
      tbc.contentSizeForViewInPopover = [320, 640]
    end

    window.rootViewController = if KK.iphone?
      tabBarController
    else
      mainController = KK.navigationForController(chartController, withDelegate:self)
      UISplitViewController.alloc.init.tap do |splitViewController|
        splitViewController.viewControllers = [tabBarController, mainController]
        splitViewController.delegate = self
      end
    end

    window.makeKeyAndVisible

    # openControllerForModel("ford--focus")

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

  ####

  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navController.setToolbarHidden(viewController.toolbarItems.nil?, animated: animated)
  end

  def splitViewController(svc, shouldHideViewController:vc, inOrientation:orientation)
    hidesMasterView # NO # KK.portrait?(orientation)
  end
  
  def splitViewController(svc, willHideViewController:vc, withBarButtonItem:bbi, forPopoverController:pc)
    bbi.title = "Options"
    chartController.navigationItem.setLeftBarButtonItems(chartController.navigationItem.leftBarButtonItems.to_a + [bbi], animated:YES)
  end
  
  def splitViewController(svc, willShowViewController:vc, invalidatingBarButtonItem:bbi)
    chartController.navigationItem.setLeftBarButtonItem(chartController.navigationItem.leftBarButtonItems.to_a - [bbi], animated:YES)
  end

  ####
  
  def setTintColors
    window.tintColor = Configuration.tintColor
    
    [UINavigationBar, UIToolbar, UISearchBar, UITabBar].each do |bar|
      bar.appearance.barTintColor = Configuration.barTintColor
      bar.appearance.tintColor    = Configuration.barIconColor
      bar.appearance.barStyle     = UIBarStyleBlack
    end

    UINavigationBar.appearance.setTitleTextAttributes NSForegroundColorAttributeName => Configuration.barTextColor
  end

  ####

  def staticContext
    @staticContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = [Mod.entity]
      
      storeURL = NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource("data/db-static", ofType:"sqlite"))
      storeOptions = {NSReadOnlyPersistentStoreOption => YES}

      # # Switches static database to the one located in the documents directory
      # if UIDevice.currentDevice.model =~ /Simulator/ 
      #   storeURL = KK.documentsURL.URLByAppendingPathComponent('data/db-static.sqlite')
      #   storeOptions = {}
      #   $devdata = true
      #   NSFileManager.defaultManager.removeItemAtURL(storeURL, error:NULL)
      # end

      storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      err = KK.ptr
      storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:storeOptions, error:err)
      raise "Can't open static database: #{err.value.description}" if err.value
      
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

      storeURL = KK.documentsURL.URLByAppendingPathComponent('db-user.sqlite')
      storeOptions = {NSMigratePersistentStoresAutomaticallyOption => YES, NSInferMappingModelAutomaticallyOption => YES}
      storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      err = KK.ptr
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
  
  
  #### development helpers
  
  def openControllerForModel(modelKey)
    controller = ModsController.new(Model.modelForKey(modelKey))
    tabBarController.selectedIndex = 2
    tabBarController.viewControllers[tabBarController.selectedIndex].pushViewController controller, animated:NO
  end
end
