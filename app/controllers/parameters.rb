class ParametersController < UITableViewController
  def viewDidLoad
    super
    self.title = "Select Parameters"
  end  
  
  def tableView(tv, numberOfRowsInSection:section)
    Model.parameters.count
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    parameter = Model.parameters[indexPath.row]

    unless cell = table.dequeueReusableCellWithIdentifier("cell")
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: "cell")
      cell.selectionStyle = UITableViewCellSelectionStyleNone
    end

    cell.textLabel.text = parameter.name
    cell.accessoryType = Model.current_parameters.include?(parameter.key) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    cell = tableView.cellForRowAtIndexPath(indexPath)
    parameter = Model.parameters[indexPath.row]
    
    if cell.accessoryType == UITableViewCellAccessoryCheckmark
      cell.accessoryType = UITableViewCellAccessoryNone
      Model.current_parameters = Model.current_parameters - [parameter.key.to_s]
    else
      cell.accessoryType = UITableViewCellAccessoryCheckmark
      Model.current_parameters = Model.current_parameters + [parameter.key.to_s]
    end
  end
end
