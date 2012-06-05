class AppDelegate
  attr_accessor :window, :navigationController
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    self.navigationController = UINavigationController.alloc.initWithRootViewController(MainViewController.alloc.init)
    navigationController.delegate = self

    self.window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    window.backgroundColor = UIColor.whiteColor
    window.rootViewController = navigationController
    window.makeKeyAndVisible
    
    return true
  end
end

class MainViewController < UITableViewController
  attr_accessor :data
  
  def viewDidLoad
    super
    self.title = "Главное окно"
    
    dataPath = NSBundle.mainBundle.pathForResource("ya-mods-parsed-bin", ofType:"plist")
    self.data = NSMutableArray.alloc.initWithContentsOfFile(dataPath)
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    return data.count
  end
  
  def tableView(tv, cellForRowAtIndexPath:ip)  
    unless cell = tv.dequeueReusableCellWithIdentifier("cell")
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"cell")
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell.textLabel.adjustsFontSizeToFitWidth = true
    end
    
    item = data[ip.row]        
    cell.textLabel.text = item['key']
    return cell
  end
end
