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
      when 0 then Model.current_mod_keys.count
      when 1 then Model.recentModKeys.count
    end
  end

  def tableView(tview, titleForHeaderInSection:section)
    case section
      when 0 then "Selected"
      when 1 then "Recent"
    end
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    collection = indexPath.section == 0 ? Model.current_mod_keys : Model.recentModKeys
    modKey = collection[-indexPath.row - 1]
    mod = Model.modification_for(modKey)
    cell = tv.dequeueReusableCell(style: UITableViewCellStyleSubtitle)
    cell.textLabel.text = mod.branded_model_name
    cell.detailTextLabel.text = mod.mod_name
    cell.accessoryType = Model.current_mod_keys.include?(mod.key) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    collection = indexPath.section == 0 ? Model.current_mod_keys : Model.recentModKeys
    modKey = collection[-indexPath.row - 1]
    
    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmark

    Model.toggleModWithKey(modKey)
    tableView.moveRowAtIndexPath(indexPath, toIndexPath:(NSIndexPath.indexPathForRow(0, inSection: indexPath.section == 0 ? 1 : 0)))
  end
end
