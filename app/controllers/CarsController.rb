class CarsController < UITableViewController
  Items = [
    {key: :recent, title: "Selected & Recent"},
    {key: :all, title: "All"},
    {key: :categories, title: "Categories"},
  ]
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped


  def initialize
    self.title = "Cars"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Cars", image:UIImage.imageNamed("ico-tab-categories.png"), tag:1)
  end

  def viewWillAppear(animated)
    super
    tableView.reloadData
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    Items.count
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    cell = table.dequeueReusableCell(klass: BadgeViewCell)
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    item = Items[indexPath.row]
    cell.textLabel.text = item[:title]
    
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    item = Items[indexPath.row]
    case item[:key]
    when :recent
      controller = RecentModificationsController.new
    when :all
      controller = ModelsController.new(Model.all)
    when :categories
      controller = CategoriesController.new
    end

    navigationController.pushViewController(controller, animated:true)
  end
end
