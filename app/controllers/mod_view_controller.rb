class ModViewController < UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped
  SystemSectionIndex = 0

  attr_accessor :mod

  def initialize(mod)
    self.mod = mod
    self.title = mod.model.name
    self.hidesBottomBarWhenPushed = KK.iphone?
  end

  def viewDidLoad
    self.tableView.tableHeaderView = KK.tableViewFooterLabel(mod.modName(Mod::NameBodyEngineVersion))
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
      cell = tv.dequeueReusableCell style:UITableViewCellStyleValue1, selectionStyle:UITableViewCellSelectionStyleNone
      cell.textLabel.text = parameter.name
      cell.detailTextLabel.text = parameter.formattedValueForMod(@mod)
      return cell
    end
  end
  
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)
    if indexPath.section == SystemSectionIndex && indexPath.item == 0
      presentNavigationController photosController, presentationStyle:UIModalPresentationFullScreen
    end
  end  
  

  
  def photosController
    @photosController ||= ModelPhotosController.new(mod.model, mod.year)
  end
end
