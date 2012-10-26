class ModController < UITableViewController
  DefaultTableViewStyleForRubyInit = UITableViewStyleGrouped
  attr_accessor :mod

  def initialize(mod)
    @mod = mod
  end

  def viewDidLoad
    self.title = mod.model.name
    tableView.tableHeaderView = ES.tableViewFooterLabel(mod.basicName)
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  ####

  def systemSectionIndex
    @systemSectionIndex ||= 0
  end

  def numberOfSectionsInTableView(tv)
    Parameter.groupKeys.count + 0
  end

  def tableView(tv, numberOfRowsInSection:section)
    # return 0 if section == systemSectionIndex
    # section -= 1
    groupKey = Parameter.groupKeys[section]
    Parameter.parametersForGroup(groupKey).count
  end

  def tableView(tv, titleForHeaderInSection:section)
    # return nil if section == systemSectionIndex
    # section -= 1
    groupKey = Parameter.groupKeys[section]
    Parameter.nameForGroup(groupKey)
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    if indexPath.section == systemSectionIndex
      # cell = tv.dequeueReusableCell(id: "HeaderCell") { |cl| cl.selectionStyle = UITableViewCellSelectionStyleNone }  
      # cell.textLabel.text = mod.basicNameWithPunctuation
      # cell.textLabel.font = ES.boldFont(20)
      # # cell.textLabel.textColor = UIColor.redColor
      # cell.textLabel.textAlignment = NSTextAlignmentCenter
      # return cell      
    end
    
    indexPath = ES.indexPath(indexPath.row, indexPath.section)
    parameter = Parameter.parametersForGroup( Parameter.groupKeys[indexPath.section] )[indexPath.row]
    cell = tv.dequeueReusableCell(style: UITableViewCellStyleValue1) { |cl| cl.selectionStyle = UITableViewCellSelectionStyleNone }
    cell.textLabel.text = parameter.name
    cell.textLabel.font = ES.boldFont(parameter.long?? 16.0 : 17.0)
    cell.detailTextLabel.text = @mod.fieldTextFor(parameter)
    cell
  end
end
