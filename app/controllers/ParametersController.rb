class ParametersController < UITableViewController
  def initialize
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Parameters", image:UIImage.imageNamed("ico-tab-parameters.png"), tag:1)
    self.title = "Parameters"
  end
  
  def tableView(tv, numberOfRowsInSection:section)
    Parameter.all.count
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    parameter = Parameter.all[indexPath.row]

    cell = table.dequeueReusableCell do |cell|
      cell.selectionStyle = UITableViewCellSelectionStyleNone
    end

    cell.textLabel.text = parameter.name
    cell.accessoryType = Disk.currentParameters.include?(parameter) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmarkAccessory

    parameter = Parameter.all[indexPath.row]
    Disk.currentParameters = Disk.currentParameters.dupWithToggledObject(parameter)
  end
end
