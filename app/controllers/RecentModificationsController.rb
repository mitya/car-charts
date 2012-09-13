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
    collectionForSection(section).count
  end

  def tableView(tv, titleForHeaderInSection:section)
    case section
      when 0 then "Selected"
      when 1 then "Recent"
    end
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    mod = modForIndexPath(indexPath)
    cell = tv.dequeueReusableCell(style: UITableViewCellStyleSubtitle)
    cell.textLabel.text = mod.model.name
    cell.detailTextLabel.text = mod.mod_name
    cell.accessoryType = Model.currentMods.include?(mod) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmarkAccessory

    mod = modForIndexPath(indexPath)
    Model.toggleModInCurrentList(mod)
    
    tableView.beginUpdates
    tableView.moveRowAtIndexPath(indexPath, toIndexPath:(NSIndexPath.indexPathForRow(0, inSection: indexPath.section == 0 ? 1 : 0)))
    tableView.endUpdates
  end
  
private

  def collectionForSection(index)
    collection = index == 0 ? Model.currentMods : Model.recentMods
  end

  def modForIndexPath(indexPath)
    collection = collectionForSection(indexPath.section)
    collection[-indexPath.row - 1]
  end
end