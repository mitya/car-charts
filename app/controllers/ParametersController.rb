class ParametersController < UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped
  
  def initialize
    self.title = "Parameters"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:UIImage.imageNamed("ico-tbi-weight"), tag:2)
  end

  def numberOfSectionsInTableView(tv)
    Parameter.groupKeys.count
  end
    
  def tableView(tv, numberOfRowsInSection: section)
    groupKey = Parameter.groupKeys[section]
    Parameter.parametersForGroup(groupKey).count
  end
  
  def tableView(tv, titleForHeaderInSection: section)
    groupKey = Parameter.groupKeys[section]
    Parameter.nameForGroup(groupKey)
  end
  
  def tableView(table, cellForRowAtIndexPath: indexPath)
    groupKey = Parameter.groupKeys[indexPath.section]
    parameter = Parameter.parametersForGroup(groupKey)[indexPath.row]
    parameterIsSelected = parameter.selected?

    cell = table.dequeueReusableCell
    cell.textLabel.text = parameter.name  
    cell.accessoryType = parameterIsSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell.textLabel.textColor = parameterIsSelected ? ES.checkedTableViewItemColor : UIColor.darkTextColor
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)
    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmarkAccessory

    groupKey = Parameter.groupKeys[indexPath.section]
    parameter = Parameter.parametersForGroup(groupKey)[indexPath.row]
    parameter.select!
  end
end
