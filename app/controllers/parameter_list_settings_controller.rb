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
    ROWS.count
  end
  
  # def tableView(tv, titleForHeaderInSection: section)
  #   Parameter.nameForGroup( Parameter.groupsKeysForCharting[section] )
  # end
  
  def tableView(table, cellForRowAtIndexPath: indexPath)
    cell = table.dequeueReusableCell
    cell.textLabel.text = ROWS[indexPath.row][:name]
    __p Disk.unitSystem, ROWS[indexPath.row][:key], Disk.unitSystem == ROWS[indexPath.row][:key]
    cell.toggleCheckmarkAccessory Disk.unitSystem == ROWS[indexPath.row][:key]
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)
    cell = tableView.cellForRowAtIndexPath(indexPath)
    Disk.unitSystem = ROWS[indexPath.row][:key]
    tableView.visibleCells.each { |c| c.accessoryType = UITableViewCellAccessoryNone }
    cell.accessoryType = UITableViewCellAccessoryCheckmark
  end
  
  ROWS = [
    {key: 'SI', name: 'Metric'},
    {key: 'UK', name: 'United Kingdom'},    
    {key: 'US', name: 'United States'}
  ]
end
