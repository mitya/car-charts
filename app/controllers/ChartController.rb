class ChartController < UITableViewController
  attr_accessor :mods, :params, :comparision, :data, :settingsNavigationController

  def viewDidLoad
    super
    @comparision = Comparision.new(Disk.currentMods, Disk.currentParameters)

    tableView.backgroundColor = Hel.pattern("bg-chart")
    tableView.rowHeight = 25
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone

    navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle("Chart", 
      style:UIBarButtonItemStyleBordered, target:nil, action:nil)
      
    navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithImage(UIImage.imageNamed("ico-bar-button-options"), 
      style:UIBarButtonItemStylePlain, target:self, action:"showSettings")
  end

  def viewWillAppear(animated)
    super
    
    @comparision = Comparision.new(Disk.currentMods.sort_by(&:key), Disk.currentParameters)
    tableView.reloadData
    self.title = "CarCharts"

    if comparision.mods.empty? || comparision.params.empty?
      view.addSubview(@placeholderView ||= createPlaceholderView)
    else
      @placeholderView.removeFromSuperview if @placeholderView && @placeholderView.superview
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
    height = BarView::BarDetailHeight
    height += BarView::BarTitleHeight if item.first?
    height += 2 if item.last?
    height += (comparision.params.count - 1) * BarView::BarFullHeight
    height += 4
    height
  end

  def navigationController(navController, willShowViewController:viewController, animated:animated)
    @closeSettingsButton ||= UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone,
      target:self, action:"closeSettings")
    viewController.navigationItem.rightBarButtonItem = @closeSettingsButton unless viewController.navigationItem.rightBarButtonItem
    navController.setToolbarHidden(viewController.toolbarItems.nil?, animated: animated)
  end

  def showSettings
    @settingsTabBarController || begin
      carsCon = CarsController.new
      carsCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical
      carsNavCon = UINavigationController.alloc.initWithRootViewController(carsCon)
      carsNavCon.delegate = self

      parametersCon = ParametersController.new
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
  
  def createPlaceholderView
    text = $lastLaunchFailed ?
      "Something weird happened, the parameters and models were reset. Sorry :(" :
      "To start – select some car models and some parameters to compare"
    $lastLaunchFailed = nil
                  
    placeholder = UILabel.alloc.initWithFrame(view.bounds.withHMargins(15))
    placeholder.text = text
    placeholder.textAlignment = UITextAlignmentCenter
    placeholder.textColor = Hel.grayShade(0.7)
    placeholder.font = UIFont.systemFontOfSize(20)    
    placeholder.numberOfLines = 0    
    placeholder
  end
end
