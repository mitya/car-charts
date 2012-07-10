class CategoriesController < UITableViewController
  def viewDidLoad
    super
    @category_names = StaticData[:category_names]
    self.title = "Car Classes"
  end  
  
  def tableView tv, numberOfRowsInSection:section
    @category_names.count
  end
  
  def tableView table, cellForRowAtIndexPath:indexPath
    category_key = @category_names.keys[indexPath.row]
    category_name = StaticData[:category_names][category_key.to_sym]

    cell = table.dequeueReusableCell
    cell.textLabel.text = category_name
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell
  end

  def tableView table, didSelectRowAtIndexPath:indexPath
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    category_key = @category_names.keys[indexPath.row]
    category_models = Model.metadata['classes'][category_key.to_s]
    
    controller = ModelsController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.model_keys = category_models    
    navigationController.pushViewController(controller, animated:true)
  end
end
