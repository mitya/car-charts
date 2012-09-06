class ChartController < UITableViewController
  attr_accessor :mods, :params, :comparision, :data, :settingsNavigationController

  def viewDidLoad
    super
    @comparision = Comparision.new(Model.currentMods, Model.current_parameters.dup)

    self.tableView.rowHeight = 25
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone # UITableViewCellSeparatorStyleSingleLine

    self.navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle("Chart", style:UIBarButtonItemStyleBordered, target:nil, action:nil)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithImage(UIImage.imageNamed("ico-bar-button-options.png"), style:UIBarButtonItemStyleBordered, target:self, action:"showSettings")
  end

  def viewWillAppear(animated)
    super
    
    @comparision = Comparision.new(Model.currentMods.sort_by { |m| m.key }, Model.current_parameters.dup)
    tableView.reloadData
    self.title = comparision.title

    if comparision.mods.empty? || comparision.params.empty?
      @messageView || begin
        @messageView = UILabel.alloc.initWithFrame(view.bounds.withXMargins(15))
        @messageView.text = "To start – select some car models and some parameters to compare"
        @messageView.textAlignment = UITextAlignmentCenter
        @messageView.textColor = Color.grayShade(0.7)
        @messageView.font = UIFont.systemFontOfSize(20)
        @messageView.numberOfLines = 0
      end
      view.addSubview(@messageView)
    else
      @messageView.removeFromSuperview if @messageView && @messageView.superview
    end

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
      carsCon = CarsController.alloc.initWithStyle(UITableViewStyleGrouped)
      carsCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical
      carsNavCon = UINavigationController.alloc.initWithRootViewController(carsCon)
      carsNavCon.delegate = self

      parametersCon = ParametersController.alloc.initWithStyle(UITableViewStyleGrouped)
      parametersCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical
      parametersNavCon = UINavigationController.alloc.initWithRootViewController(parametersCon)
      parametersNavCon.delegate = self
      
      @settingsTabBarController = UITabBarController.new
      @settingsTabBarController.viewControllers = [carsNavCon, parametersNavCon]
    end
    
    presentViewController @settingsTabBarController, animated:true, completion:nil
  end
  
  def closeSettings
    dismissModalViewControllerAnimated true
  end

  def navigationController(navController, willShowViewController:viewController, animated:animated)
    @closeSettingsButton ||= UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone, target:self, action:"closeSettings")
    viewController.navigationItem.rightBarButtonItem = @closeSettingsButton unless viewController.navigationItem.rightBarButtonItem
    navController.setToolbarHidden(viewController.toolbarItems.nil?, animated: animated)
  end
end
