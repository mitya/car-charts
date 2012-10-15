class AppDelegate
  attr_accessor :window, :navigationController
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @exceptionHandler = proc { |exception| applicationFailedWithException(exception) }
    NSSetUncaughtExceptionHandler(@exceptionHandler)

    Disk.load
    Disk.currentParameters ||= [Parameter.by(:max_power)]
    Disk.currentMods ||= []

    if NSUserDefaults.standardUserDefaults["crashed"]
      NSLog "Recovering after crash ..."
      Disk.recentMods = Disk.currentMods + Disk.recentMods
      Disk.currentMods = []
      Disk.currentParameters = []
      NSUserDefaults.standardUserDefaults.removeObjectForKey("crashed")
      $lastLaunchFailed = true
    end    

    self.navigationController = UINavigationController.alloc.initWithRootViewController(ChartController.alloc.init)
    navigationController.delegate = self

    # controller = ModsController.new(Model.by("ford--focus"))
    # controller = IndexedModelsController.new(Model.byCategoryKey("C"))
    # controller = ParametersController.new
    # controller = RecentModsController.new
    # controller = ModSetsController.new
    navigationController.pushViewController controller, animated:NO if defined?(controller)

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    window.backgroundColor = UIColor.whiteColor
    window.rootViewController = navigationController
    window.makeKeyAndVisible
    
    return true
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
    Hel.defaults.synchronize
  end

  def applicationFailedWithException(exception)
    NSUserDefaults.standardUserDefaults["crashed"] = true
    stack = exception.callStackReturnAddresses
    NSLog "FATAL ERROR: #{exception}"
  end

  ####

  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navigationController.setToolbarHidden(viewController.toolbarItems.nil?, animated: animated)
  end

  ####

  def staticContext
    @staticContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = [Mod.entity]

      # storeURL = Hel.documentsURL.URLByAppendingPathComponent('db-static.sqlite')
      storeURL = NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource("db-static", ofType:"sqlite"))
      storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      err = Hel.newErr
      unless storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:{}, error:err)
        raise "Can't add persistent SQLite store: #{err[0].description}"
      end

      context = NSManagedObjectContext.alloc.init
      context.persistentStoreCoordinator = storeCoordinator
      context
    end
  end

  def userContext
    @userContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = [ModSet.entity]

      storeURL = Hel.documentsURL.URLByAppendingPathComponent('db-user.sqlite')      
      storeOptions = {NSMigratePersistentStoresAutomaticallyOption => YES, NSInferMappingModelAutomaticallyOption => YES}
      storeCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      err = Hel.newErr
      unless storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:storeOptions, error:err)
        raise "Can't add persistent SQLite store: #{err[0].description}"
      end

      context = NSManagedObjectContext.alloc.init
      context.persistentStoreCoordinator = storeCoordinator
      context
    end
  end  

  def saveObjectContext(context = userContext)
    errorPtr = Pointer.new(:object)
    unless context.save(errorPtr)
      raise "Error when saving the model: #{errorPtr[0].description}"
    end
  end
  
  # def testSQL
  #   db = Pointer.new(:object)
  #   dbPath = NSBundle.mainBundle.pathForResource("db-static", ofType:"sqlite")
  #   
  #   if sqlite3_open(dbPath.UTF8String, db) == SQLITE_OK
  #     sqlStatement = "select zmodel_title from zmod limit 20".UTF8String
  #     compiledStatement = Pointer.new(:object)
  #     if sqlite3_prepare_v2(db, sqlStatement, -1, compiledStatement, NULL) == SQLITE_OK
  #       while sqlite3_step(compiledStatement) == SQLITE_ROW
  #         p NSString.stringWithUTF8String(sqlite3_column_text(compiledStatement, 1))
  #       end
  #     end
  #     sqlite3_finalize(compiledStatement)
  #   end
  #   sqlite3_close(db)
  # end
end
