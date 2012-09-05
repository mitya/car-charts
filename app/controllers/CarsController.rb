class CarsController < UITableViewController
  Items = [
    {key: :recent, title: "Selected & Recent"},
    {key: :all, title: "All"},
    {key: :categories, title: "Categories"},
  ]
  
  def initWithStyle(style)
    super
    self.title = "Cars"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Cars", image:UIImage.imageNamed("ico-tab-categories.png"), tag:1)
    @category_names = Static.category_names
    self
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
      controller = RecentModificationsController.alloc.initWithStyle(UITableViewStyleGrouped)
    when :all
      controller = ModelsController.alloc.initWithStyle(UITableViewStyleGrouped)
      controller.model_keys = Model.all_model_keys
    when :categories
      controller = CategoriesController.alloc.initWithStyle(UITableViewStyleGrouped)
    end

    navigationController.pushViewController(controller, animated:true)
  end
end
