class ModelsController < UITableViewController
  attr_accessor :model_keys
  
  def viewDidLoad
    super
    self.title = "Car Models"
  end  
  
  def tableView tv, numberOfRowsInSection:section
    @model_keys.count
  end
  
  def tableView table, cellForRowAtIndexPath:indexPath
    model_key = @model_keys[indexPath.row]
    model_name = Model.metadata['branded_model_names'][model_key] || model_key

    unless cell = table.dequeueReusableCellWithIdentifier("cell")
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:"cell")
    end

    cell.textLabel.text = model_name
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator    
    cell
  end

  def tableView table, didSelectRowAtIndexPath:indexPath
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    model_key = @model_keys[indexPath.row]
    
    controller = ModificationsController.alloc.initWithStyle(UITableViewStyleGrouped)
    controller.model_key = model_key
    navigationController.pushViewController(controller, animated:true)  
  end
end
