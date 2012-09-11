class AppDelegate
  attr_accessor :window, :navigationController
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    NSSetUncaughtExceptionHandler nil do |exception|
      NSLog "the handler block"
      applicationFailedWithException(exception)
    end
    
    Model.load
    Model.currentParameters ||= [Parameter.get(:max_power)]
    Model.currentMods ||= []

    if NSUserDefaults.standardUserDefaults["crashed"]
      NSLog "Recoivering after crash"
      Model.recentMods = Model.currentMods + Model.recentMods
      Model.currentMods = []
      Model.currentParameters = []
      NSUserDefaults.standardUserDefaults.removeObjectForKey("crashed")
      $lastLaunchFailed = true
    end    

    self.navigationController = UINavigationController.alloc.initWithRootViewController(ChartController.alloc.init)
    navigationController.delegate = self

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
    NSLog "applicationFailedWithException"
    NSUserDefaults.standardUserDefaults["crashed"] = true
    stack = exception.callStackReturnAddresses
    NSLog "Disaster: #{exception}\nStack: #{stack}"
  end
end

