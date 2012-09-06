class ParametersController < UITableViewController
  def initWithStyle(style)
    super
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Parameters", image:UIImage.imageNamed("ico-tab-parameters.png"), tag:1)
    self.title = "Parameters"
    self
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    Model.parameters.count
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    parameter = Model.parameters[indexPath.row]

    cell = table.dequeueReusableCell do |cell|
      cell.selectionStyle = UITableViewCellSelectionStyleNone
    end

    cell.textLabel.text = parameter.name
    cell.accessoryType = Model.currentParameters.include?(parameter.key) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    cell = tableView.cellForRowAtIndexPath(indexPath)
    parameter = Model.parameters[indexPath.row]

    if cell.toggleCheckmark
      Model.currentParameters = Model.currentParameters - [parameter.key.to_s]      
    else
      Model.currentParameters = Model.currentParameters + [parameter.key.to_s]
    end
  end
end
