class AppDelegate
  attr_accessor :window, :tabBarController, :chartController, :hidesMasterView
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSSetUncaughtExceptionHandler(@exceptionHandler = proc { |exception| applicationDidFailWithException(exception) })

    self.hidesMasterView = NO

    Disk.load
    recoverAfterCrash if NSUserDefaults.standardUserDefaults["crashed"]

    UINavigationBar.appearance.tintColor = Configuration.tintColor
    UIToolbar.appearance.tintColor = Configuration.tintColor
    UITabBar.appearance.tintColor = Configuration.tintColor

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap { |w| w.backgroundColor = UIColor.whiteColor }

    self.chartController = ChartController.new
    self.tabBarController = UITabBarController.new.tap do |tbc|
      tabControllers = [chartController, ParametersController.new, ModelsController.new, RecentModsController.new, ModSetsController.new]
      tabControllers.shift if ipad?
      tbc.viewControllers = tabControllers.map { |ctr| KK.navigationForController(ctr, withDelegate:self) }
      tbc.delegate = self
      tbc.selectedIndex = 0
      tbc.contentSizeForViewInPopover = [320, 640]
    end

    window.rootViewController = if iphone?
      tabBarController
    else
      mainController = KK.navigationForController(chartController, withDelegate:self)
      UISplitViewController.alloc.init.tap do |splitViewController|
        splitViewController.viewControllers = [tabBarController, mainController]
        splitViewController.delegate = self
      end
    end

    # tempController = KKStringListController.new
    # window.rootViewController = tempController

    window.makeKeyAndVisible

    # controller = ModController.new(Mod.modForKey("citroen c5 2007 sedan 2.0i-143ps-AT-FWD"))
    # controller = ModsController.new(Model.modelForKey("ford--focus"))
    # tabBarController.selectedIndex = 2
    # tabBarController.viewControllers[tabBarController.selectedIndex].pushViewController controller, animated:NO

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

  def staticContext
    @staticContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = [Mod.entity]
      
      storeURL = NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource("db-static", ofType:"sqlite"))
      storeOptions = {NSReadOnlyPersistentStoreOption => YES}

      # # Switches static database to the one located in the documents directory
      # if UIDevice.currentDevice.model =~ /Simulator/ 
      #   storeURL = KK.documentsURL.URLByAppendingPathComponent('db-static.sqlite')
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
end