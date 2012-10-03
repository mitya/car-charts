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

    navigationController.pushViewController ModificationsController.new(Model.by("ford--focus")), animated:NO
    # navigationController.pushViewController ModelsIndexedController.new(Model.byCategoryKey("C")), animated:NO
    # navigationController.pushViewController ParametersController.new, animated:NO
    # navigationController.pushViewController ModificationSetsController.new, animated:NO

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    window.backgroundColor = UIColor.whiteColor
    window.rootViewController = navigationController
    window.makeKeyAndVisible
    
    return true
  end
  
  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navigationController.setToolbarHidden(viewController.toolbarItems.nil?, animated: animated)
  end

  def applicationFailedWithException(exception)
    NSUserDefaults.standardUserDefaults["crashed"] = true
    stack = exception.callStackReturnAddresses
    NSLog "Disaster: #{exception.inspect}\nStack: #{stack}"
  end
end
