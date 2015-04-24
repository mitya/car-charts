class ParameterListController < UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped
  
  def initialize
    self.title = "Parameters"
    self.tabBarItem = UITabBarItem.alloc.initWithTitle(title, image:KK.image("tab-funnel"), selectedImage:KK.image("tab-funnel-full"))    
    # self.canDisplayBannerAds = KK.app.delegate.showsBannerAds?
    Disk.addObserver(self, forKeyPath:"unitSystem", options:NO, context:nil)
  end
  
  def dealloc
    KK.debug 'ParameterListController.dealloc'
    Disk.removeObserver(self, forKeyPath:"unitSystem")
    super
  end
    
  def viewDidLoad
    navigationItem.rightBarButtonItem = KK.imageBBI("bar-gear", target:self, action:'showSettings')
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    case keyPath when 'unitSystem'
      tableView.reloadData
    end
  end
  
  def numberOfSectionsInTableView(tv)
    Parameter.groupsKeysForCharting.count
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end  
    
  def tableView(tv, numberOfRowsInSection: section)
    Parameter.chartableParametersForGroup( Parameter.groupsKeysForCharting[section] ).count
  end
  
  def tableView(tv, titleForHeaderInSection: section)
    Parameter.nameForGroup( Parameter.groupsKeysForCharting[section] )
  end
  
  def tableView(table, cellForRowAtIndexPath: indexPath)
    groupKey = Parameter.groupsKeysForCharting[indexPath.section]
    parameter = Parameter.chartableParametersForGroup(groupKey)[indexPath.row]

    cell = table.dequeueReusableCell
    cell.textLabel.text = parameter.localizedName
    cell.toggleCheckmarkAccessory(parameter.selected?)
    cell
  end  
  
  def tableView(table, didSelectRowAtIndexPath:indexPath)
    groupKey = Parameter.groupsKeysForCharting[indexPath.section]
    parameter = Parameter.chartableParametersForGroup(groupKey)[indexPath.row]
    parameter.select!
    
    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
  end
  
  def showSettings
    @settingsController ||= ParameterListSettingsController.new
    if KK.iphone?
      navigationController.pushViewController @settingsController, animated:true
    else
      presentPopoverController @settingsController, fromBarItem:navigationItem.rightBarButtonItem
    end    
  end
  
  def screenKey
    { parameters: Disk.currentParameters.count }
  end  
end
