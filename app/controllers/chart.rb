class ChartController < UITableViewController
  attr_accessor :mods, :params, :comparision, :data, :settingsNavigationController

  def viewDidLoad
    super
    # @mods = Model.current_models.map { |model_key| Model.modifications_by_model_key[model_key] }.flatten.select(&:automatic?)
    @comparision = Comparision.new(Model.current_mods, Model.current_parameters.dup)

    self.tableView.rowHeight = 25
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone # UITableViewCellSeparatorStyleSingleLine

    self.navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle("Chart", style:UIBarButtonItemStyleBordered, target:nil, action:nil)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithImage(UIImage.imageNamed("abc_Op.png"), style:UIBarButtonItemStyleBordered, target:self, action:"showSettings")
  end

  def viewWillAppear(animated)
    super    
    # if comparision.params != Model.current_parameters
    @comparision = Comparision.new(Model.current_mods.sort_by { |m| m.key }, Model.current_parameters.dup)
    tableView.reloadData
    self.title = comparision.title
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  def tableView(tv, numberOfRowsInSection:section)
    @comparision.mods.count
  end
  
  def tableView(tv, cellForRowAtIndexPath:ip)
    cell = tv.dequeueReusableCell klass:BarTableViewCell do |cell|
      cell.selectionStyle = UITableViewCellSelectionStyleNone
    end
        
    cell.item = comparision.items[ip.row]
    cell
  end
  
  def tableView(tv, heightForRowAtIndexPath:ip)
    item = comparision.items[ip.row]
    height = BarDetailHeight
    height += BarTitleHeight if item.first?
    height += 2 if item.last?
    height += (comparision.params.count - 1) * BarFullHeight
    height += 4
    height
  end
  
  def showParameters
    controller = ParametersController.alloc.initWithStyle(UITableViewStyleGrouped)
    navigationController.pushViewController(controller, animated:true)
  end  

  def showCategories
    controller = CategoriesController.alloc.initWithStyle(UITableViewStyleGrouped)
    navigationController.pushViewController(controller, animated:true)
  end  
  
  def showSettings
    @settingsTabBarController || begin
      categoriesCon = CategoriesController.alloc.initWithStyle(UITableViewStyleGrouped)
      categoriesCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical
      categoriesNavCon = UINavigationController.alloc.initWithRootViewController(categoriesCon)
      categoriesNavCon.delegate = self

      parametersCon = ParametersController.alloc.initWithStyle(UITableViewStyleGrouped)
      parametersCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical
      parametersNavCon = UINavigationController.alloc.initWithRootViewController(parametersCon)
      parametersNavCon.delegate = self
      
      @settingsTabBarController = UITabBarController.new
      @settingsTabBarController.viewControllers = [categoriesNavCon, parametersNavCon]
    end
    
    presentViewController @settingsTabBarController, animated:true, completion:nil
  end
  
  def closeSettings
    dismissModalViewControllerAnimated true
  end

  def navigationController(navController, willShowViewController:viewController, animated:animated)
    @closeSettingsButton ||= UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:"closeSettings")
    viewController.navigationItem.rightBarButtonItem = @closeSettingsButton unless viewController.navigationItem.rightBarButtonItem
  end
end
