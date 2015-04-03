class ParameterListSettingsController < UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped
  
  def initialize
    self.title = "Settings"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("tab-funnel"), selectedImage:KK.image("tab-funnel-full"))
  end

  # def numberOfSectionsInTableView(tv)
  #   1
  # end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end  
    
  def tableView(tv, numberOfRowsInSection: section)
    2
  end
  
  # def tableView(tv, titleForHeaderInSection: section)
  #   Parameter.nameForGroup( Parameter.groupsKeysForCharting[section] )
  # end
  
  def tableView(table, cellForRowAtIndexPath: indexPath)
    cell = table.dequeueReusableCell
    cell.textLabel.text = OPTIONS[indexPath.row]
    cell.toggleCheckmarkAccessory(currentParameterUnitIndex == indexPath.row)
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)
    cell = tableView.cellForRowAtIndexPath(indexPath)
    Disk.parameterUnits = 'metric' if indexPath.row == 0
    Disk.parameterUnits = 'imperial' if indexPath.row == 1    
    tableView.visibleCells.each   { |cell| cell.toggleCheckmarkAccessory }
  end
  
  def currentParameterUnitIndex
    Disk.parameterUnits == 'metric' ? 0 : 1
  end
  
  OPTIONS = ['Metric', 'Imperial']
end
