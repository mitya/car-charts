class CarsController < UITableViewController
  Items = [
    {key: :all, title: "All"},
    {key: :categories, title: "Categories"},
  ]
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped

  def initialize
    self.title = "Models"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Models", image:UIImage.imageNamed("ico-tbi-car"), tag:1)
    navigationItem.backBarButtonItem = ES.textBBI("Back")
  end

  def viewWillAppear(animated)
    super
    tableView.reloadData
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    Items.count
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    cell = table.dequeueReusableCell(klass: DSBadgeViewCell)
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    item = Items[indexPath.row]
    cell.textLabel.text = item[:title]
    
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    item = Items[indexPath.row]
    controller = case item[:key]
      when :recent then RecentModsController.new
      when :all then IndexedModelsController.new(Model.all)
      when :categories then CategoriesController.new
      when :sets then ModSetsController.new
    end

    navigationController.pushViewController(controller, animated:true)
  end
end
