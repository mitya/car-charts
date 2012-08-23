class AppDelegate
  attr_accessor :window, :navigationController
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    ModelManager.load
    Model.current_parameters ||= [:max_power]
    Model.current_mod_keys ||= [] # %w(ford--focus volkswagen--golf honda--civic toyota--corolla)

    self.navigationController = UINavigationController.alloc.initWithRootViewController(ChartController.alloc.init)
    navigationController.delegate = self

    controller = ModificationsController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.model_key = "ford--focus"
    navigationController.pushViewController(controller, animated:false)

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    window.backgroundColor = UIColor.whiteColor
    window.rootViewController = navigationController
    window.makeKeyAndVisible
    
    return true
  end
end
