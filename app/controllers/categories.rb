class CategoriesController < UITableViewController
  def initWithStyle(style)
    super
    self.title = "Car Classes"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Cars", image:UIImage.imageNamed("abc_Cc.png"), tag:1)
    @category_names = Static.category_names
    self
  end  
  
  def viewWillAppear(animated)
    super
    tableView.reloadData
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    @category_names.count
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    category_key = @category_names.keys[indexPath.row]
    category_name = Static.category_names[category_key.to_sym]
    category_models = Model.model_classes[category_key.to_s]
    category_selected_mods_count = Model.current_mods.map(&:category).map(&:to_sym).select{ |c| c == category_key}.count

    cell = table.dequeueReusableCell(klass: BadgeViewCell)
    cell.textLabel.text = category_name
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.badgeText = category_selected_mods_count.to_s if category_selected_mods_count > 0    
    cell    
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    category_key = @category_names.keys[indexPath.row]
    category_models = Model.model_classes[category_key.to_s]
    
    controller = ModelsController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.model_keys = category_models    
    navigationController.pushViewController(controller, animated:true)
  end
end
