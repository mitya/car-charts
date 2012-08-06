class ModelsController < UITableViewController
  attr_accessor :model_keys
  
  def viewDidLoad
    super
    self.title = "Car Models"
  end  

  def viewWillAppear(animated)
    super
    tableView.reloadData
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    @model_keys.count
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    model_key = @model_keys[indexPath.row]
    model_name = Model.model_names_branded[model_key] || model_key
    model_selected_mods_count = Model.current_mods.map(&:model_key).select{ |key| key == model_key}.count

    cell = table.dequeueReusableCell(klass: BadgeViewCell)
    cell.textLabel.text = model_name
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    cell.badgeText = model_selected_mods_count.to_s if model_selected_mods_count > 0
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    model_key = @model_keys[indexPath.row]

    controller = ModificationsController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.model_key = model_key
    navigationController.pushViewController(controller, animated:true)  
  end
end
