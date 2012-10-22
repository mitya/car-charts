class ModController < UITableViewController
  attr_accessor :mod

  def initialize(mod)
    @mod = mod
  end

  def viewDidLoad
    self.title = mod.fullName
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  ####

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

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    groupKey = Parameter.groupKeys[indexPath.section]
    parameter = Parameter.parametersForGroup(groupKey)[indexPath.row]
    cell = tv.dequeueReusableCell(style: UITableViewCellStyleValue1) { |cl| cl.selectionStyle = UITableViewCellSelectionStyleNone }
    cell.textLabel.text = parameter.name
    cell.detailTextLabel.text = @mod.fieldTextFor(parameter)
    cell
  end
end
