class AppDelegate
  attr_accessor :window, :navigationController
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    Model.load
    Model.currentParameters ||= [Parameter.get(:max_power)]
    Model.currentMods ||= []

    self.navigationController = UINavigationController.alloc.initWithRootViewController(ChartController.alloc.init)
    navigationController.delegate = self

    # controller = ModificationsController.alloc.initWithStyle(UITableViewStyleGrouped)
    # controller.model = Make.get("ford--focus")
    # navigationController.pushViewController(controller, animated:false)

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    window.backgroundColor = UIColor.whiteColor
    window.rootViewController = navigationController
    window.makeKeyAndVisible
    
    return true
  end
  
  def navigationController(navController, willShowViewController:viewController, animated:animated)
    navigationController.setToolbarHidden(viewController.toolbarItems.nil?, animated: animated)
  end  
end
