class RecentModificationsController < UITableViewController
  attr_accessor :current, :recent
  
  def viewDidLoad
    super
    self.title = "Recent Models"
  end
  
  def numberOfSectionsInTableView(tv)
    2
  end

  def tableView(tv, numberOfRowsInSection:section)
    case section
      when 0 then Model.currentMods.count
      when 1 then Model.recentMods.count
    end
  end

  def tableView(tview, titleForHeaderInSection:section)
    case section
      when 0 then "Selected"
      when 1 then "Recent"
    end
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    collection = indexPath.section == 0 ? Model.currentMods : Model.recentMods
    mod = collection[-indexPath.row - 1]
    cell = tv.dequeueReusableCell(style: UITableViewCellStyleSubtitle)
    cell.textLabel.text = mod.model.name
    cell.detailTextLabel.text = mod.mod_name
    cell.accessoryType = Model.currentMods.include?(mod) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    collection = indexPath.section == 0 ? Model.currentMods : Model.recentMods
    
    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmark

    mod = collection[-indexPath.row - 1]
    mod.toggle
    
    tableView.moveRowAtIndexPath(indexPath, toIndexPath:(NSIndexPath.indexPathForRow(0, inSection: indexPath.section == 0 ? 1 : 0)))
  end
end
