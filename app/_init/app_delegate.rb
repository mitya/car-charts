class AppDelegate
  include GlobalHelpers
  attr_accessor :window
  attr_accessor :tabBarController, :splitViewContorller, :bannerViewController
  attr_accessor :modelListController, :chartController
  attr_accessor :hidesMasterView

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    KK.profileBegin 'didFinishLaunchingWithOptions'

    Flurry.startSession FLURRY_TOKEN if FLURRY_ENABLED

    NSSetUncaughtExceptionHandler(@exceptionHandler = proc { |exception| applicationDidFailWithException(exception) })

    self.hidesMasterView = NO

    KK.profile 'flurry'

    Disk.load
    recoverAfterCrash if NSUserDefaults.standardUserDefaults["crashed"]
    Mod.randomMod

    KK.profile 'disk'

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

      if KK.env?('CCNoAds')
        splitViewContorller
      else
        self.bannerViewController = BannerViewController.alloc.initWithContentViewController(splitViewContorller)
      end
    end

    window.makeKeyAndVisible

    setTintColors

    KK.profileEnd 'all'

    # openControllerForModel("ford--focus--2014")

    true
  end

  def applicationWillTerminate(application)
    saveObjectContext
    KK.defaults.synchronize
  end

  def applicationDidFailWithException(exception)
    NSUserDefaults.standardUserDefaults["crashed"] = true    

    if FLURRY_ENABLED
      Flurry.logError exception.name, message:exception.reason, exception:exception
      NSLog "Logged error to Flurry"
    end

    # NSLog "FATAL ERROR: #{exception}"
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

  ENCRYPTION = true
  DB_NAME = "mods-150424.db"

  def staticContext
    @staticContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = [Mod.entity]

      fileManager = NSFileManager.defaultManager
      appBundle = NSBundle.mainBundle
      userDefaults = NSUserDefaults.standardUserDefaults

      if ENCRYPTION
        copyDir = KK.documentsPath.stringByAppendingPathComponent("dbcopy")
        copyPath = copyDir.stringByAppendingPathComponent(DB_NAME)

        options = {}
        options[EncryptedStorePassphraseKey] = 'db/mods' + 'firstLaunchTime'.sub('Launch', '') + 123_347_957_156_765.to_s(16)
        options[EncryptedStoreDatabaseLocation] = copyPath

        if KK.env?('CCTestModsDataset')
          if KK.env?('CCTestModsDatasetRun')
            fileManager.removeItemAtURL copyDir, error:NULL
            fileManager.createDirectoryAtPath copyDir, withIntermediateDirectories:NO, attributes:NIL, error:NULL
          end
        else
          if userDefaults["firstLaunchTime"] == nil || !fileManager.fileExistsAtPath(copyPath)
            NSLog "Copying the #{DB_NAME} database from the app bundle"
            error = KK.ptr
            seedPath = appBundle.resourcePath.stringByAppendingPathComponent('db').stringByAppendingPathComponent(DB_NAME)
            fileManager.removeItemAtPath copyDir, error:NULL
            fileManager.createDirectoryAtPath copyDir, withIntermediateDirectories:NO, attributes:NIL, error:error
            fileManager.copyItemAtPath seedPath, toPath:copyPath, error:error
          end
          
          if error
            NSLog("Seed Error: #{error.value.description}")
            Flurry.logError 'Seed Error', message:error.value.description, error:error.value
          end
        end

        storeCoordinator = EncryptedStore.makeStoreWithOptions options, managedObjectModel:model

      else
        # if KK.env?('CCTestModsDataset')
        #   storeURL = KK.documentsURL.URLByAppendingPathComponent('mods.sqlite')
        #   storeOptions = {}
        #   NSFileManager.defaultManager.removeItemAtURL(storeURL, error:NULL) if KK.env?('CCTestModsDatasetRun')
        # else
        #   storeURL ||= NSBundle.mainBundle.URLForResource("db/mods", withExtension:"sqlite")
        #   storeOptions ||= {NSReadOnlyPersistentStoreOption => YES}
        # end
        #
        # err = KK.ptr
        # storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
        # storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:storeOptions, error:err)
        # NSLog "Can't open static database: #{err.value.description}" if err.value
      end

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
    Disk.currentParameters = []
  end

  def setTintColors
    window.tintColor = Configuration.tintColor

    [UINavigationBar, UIToolbar, UISearchBar, UITabBar].each do |bar|
      bar.appearance.barTintColor = Configuration.barTintColor
      bar.appearance.tintColor = Configuration.barIconColor
      bar.appearance.barStyle = UIBarStyleBlack
    end

    UITabBar.appearance.barTintColor = Configuration.tabBarTintColor

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
    return false if KK.env?('CCNoAds')
    KK.iphone?
  end
  
  def adsEnabled?
    KK.env?('CCNoAds') ? false : true
  end
end
