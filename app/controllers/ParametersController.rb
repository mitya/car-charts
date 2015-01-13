class ParametersController < UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped
  
  def initialize
    self.title = "Parameters"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("ti-speedometer"), tag:2)
  end

  def numberOfSectionsInTableView(tv)
    Parameter.groupKeys.count
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end  
    
  def tableView(tv, numberOfRowsInSection: section)
    Parameter.chartableParametersForGroup( Parameter.groupKeys[section] ).count
  end
  
  def tableView(tv, titleForHeaderInSection: section)
    Parameter.nameForGroup( Parameter.groupKeys[section] )
  end
  
  def tableView(table, cellForRowAtIndexPath: indexPath)
    groupKey = Parameter.groupKeys[indexPath.section]
    parameter = Parameter.chartableParametersForGroup(groupKey)[indexPath.row]

    cell = table.dequeueReusableCell
    cell.textLabel.text = parameter.name
    cell.toggleCheckmarkAccessory(parameter.selected?)
    return cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)
    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmarkAccessory

    groupKey = Parameter.groupKeys[indexPath.section]
    parameter = Parameter.chartableParametersForGroup(groupKey)[indexPath.row]
    parameter.select!
  end
end
