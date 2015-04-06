class ModViewController < UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped
  SystemSectionIndex = 0

  attr_accessor :mod

  def initialize(mod)
    self.mod = mod
    self.title = mod.model.family.name
    navigationItem.rightBarButtonItem = KK.systemBBI(UIBarButtonSystemItemDone, target:self, action:'close') if KK.ipad?
    Disk.addObserver(self, forKeyPath:"unitSystem", options:NO, context:nil)
  end

  def dealloc
    Disk.removeObserver(self, forKeyPath:"unitSystem")
    super
  end

  def viewDidLoad
    self.tableView.tableHeaderView = KK.tableViewFooterLabel(mod.modName(Mod::NameBodyEngineVersionYear))
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    case keyPath when 'unitSystem'
      tableView.reloadData
    end
  end

  def numberOfSectionsInTableView(tv)
    Parameter.groupKeys.count + 1
  end

  def tableView(tv, numberOfRowsInSection:section)
    return 1 if section == SystemSectionIndex
    section -= 1
    
    groupKey = Parameter.groupKeys[section]
    Parameter.parametersForGroup(groupKey).count
  end

  def tableView(tv, titleForHeaderInSection:section)
    return nil if section == SystemSectionIndex
    section -= 1    
    
    groupKey = Parameter.groupKeys[section]
    Parameter.nameForGroup(groupKey)
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    if indexPath.section == SystemSectionIndex
      cell = tv.dequeueReusableCell id:'Action', style:UITableViewCellStyleDefault, accessoryType:UITableViewCellAccessoryDisclosureIndicator do |cell|
        cell.textLabel.text = "Photos"
        cell.imageView.image = KK.image("ci-google")
      end
    else
      parameter = Parameter.parametersForGroup( Parameter.groupKeys[indexPath.section - 1] )[indexPath.row]
      cell = tv.dequeueReusableCell style:UITableViewCellStyleValue1, selectionStyle:UITableViewCellSelectionStyleNone do |cell|
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES
        cell.detailTextLabel.numberOfLines = 1
        cell.textLabel.numberOfLines = 1
      end
    
      cell.textLabel.text = parameter.localizedName
      cell.detailTextLabel.text = @mod.parameterValue(parameter.key).string(Disk.unitSystem)

      if parameter.key == 'consumption_string'
        cell.textLabel.numberOfLines = 0
        cell.detailTextLabel.numberOfLines = 0
        cell.textLabel.text = "Consumption\ncity / highway / combined"
      end

      cell
    end
  end
  
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)
    showPhotos if indexPath.section == SystemSectionIndex && indexPath.item == 0
  end  
  
  def tableView(tv, heightForRowAtIndexPath:ip)
    return super if ip.section == SystemSectionIndex
    parameter = Parameter.parametersForGroup( Parameter.groupKeys[ip.section - 1] )[ip.row]
    parameter.key == 'consumption_string' ? TWO_LINE_ROW_HEIGHT : super
  end
  
  def close
    dismissSelfAnimated
  end  

  def photosController
    @photosController ||= ModelPhotosController.new(mod.model, mod.year)
  end
  
  def showPhotos
    if KK.iphone?
      navigationController.pushViewController photosController, animated:true
    else
      presentNavigationController photosController, presentationStyle:UIModalPresentationFullScreen
    end    
  end
  
  def self.showFor(presentingController, withMod:mod)
    controller = new(mod)
    if KK.iphone?
      presentingController.navigationController.pushViewController controller, animated:true
    else
      presentingController.presentNavigationController controller, presentationStyle:UIModalPresentationFormSheet, transitionStyle:UIModalTransitionStyleCoverVertical
    end   
  end
end
