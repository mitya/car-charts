class ParametersController < UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped
  
  def initialize
    self.title = "Parameters"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle("Parameters", image:UIImage.imageNamed("ico-tbi-weight"), tag:1)
  end

  def viewDidLoad
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  def numberOfSectionsInTableView(tv)
    Parameter.groupKeys.count
  end
    
  def tableView(tv, numberOfRowsInSection:section)
    groupKey = Parameter.groupKeys[section]
    Parameter.parametersForGroup(groupKey).count
  end
  
  def tableView(tv, titleForHeaderInSection:section)
    groupKey = Parameter.groupKeys[section]
    Parameter.nameForGroup(groupKey)
  end
  
  def tableView(table, cellForRowAtIndexPath:indexPath)
    groupKey = Parameter.groupKeys[indexPath.section]
    parameter = Parameter.parametersForGroup(groupKey)[indexPath.row]

    cell = table.dequeueReusableCell { |cell| cell.selectionStyle = UITableViewCellSelectionStyleNone }
    cell.textLabel.text = parameter.name  
    cell.accessoryType = Disk.currentParameters.include?(parameter) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmarkAccessory

    groupKey = Parameter.groupKeys[indexPath.section]
    parameter = Parameter.parametersForGroup(groupKey)[indexPath.row]

    Disk.currentParameters = Disk.currentParameters.dupWithToggledObject(parameter)
  end
end
