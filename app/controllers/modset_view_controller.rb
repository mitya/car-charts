class ModSetViewController < UITableViewController
  attr_accessor :set

  def initialize(set)
    @set = set
  end

  def viewDidLoad
    self.title = set.name
    self.navigationItem.rightBarButtonItem = actionsButtonItem
  end

  def viewWillAppear(animated)
    super
    tableView.reloadData
  end

  def willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
    KK.app.delegate.willAnimateRotationToInterfaceOrientation(newOrientation, duration:duration)
  end  
  
  

  def tableView(tv, numberOfRowsInSection:section)    
    actionsButtonItem.enabled = !empty?
    @set.mods.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    mod = @set.mods[indexPath.row]

    cell = tv.dequeueReusableCell klass:CheckmarkCell, style:UITableViewCellStyleSubtitle, accessoryType:UITableViewCellAccessoryDetailButton
    cell.textLabel.text = mod.model.name
    cell.detailTextLabel.text = mod.modName(Mod::NameBodyEngineVersion)
    cell.toggleLeftCheckmarkAccessory(mod.selected?)
    cell
  end

  def tableView(tv, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    case editingStyle when UITableViewCellEditingStyleDelete
      mod = @set.mods[indexPath.row]
      @set.deleteMod(mod)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
    end
  end

  def tableView(tableView, moveRowAtIndexPath:fromIndexPath, toIndexPath:toIndexPath)
    set.swapMods(fromIndexPath.row, toIndexPath.row)
  end
  
  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)
    tableView.cellForRowAtIndexPath(indexPath).toggleLeftCheckmarkAccessory
    @set.mods[indexPath.row].select!
  end
    
  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
    mod = @set.mods[indexPath.row]
    navigationController.pushViewController ModViewController.new(mod), animated:YES
  end
    

  
  def setEditing(editing, animated:animated)
    super
    navigationItem.rightBarButtonItem = isEditing ? editButtonItem : actionsButtonItem
  end
  
  def actionsButtonItem
    @actionsButtonItem ||= KK.systemBBI(UIBarButtonSystemItemAction, target:self, action:'showSetActionSheet:')
  end
  

  
  def showSetActionSheet(bbi)
    sheet = UIActionSheet.alloc.initWithTitle(NIL, delegate:self, cancelButtonTitle:"Cancel", destructiveButtonTitle:NIL, otherButtonTitles:NIL)
    sheet.addButtonWithTitle "Add All to Chart"
    sheet.addButtonWithTitle "Replace All on Chart"
    sheet.addButtonWithTitle "Edit Set"
    sheet.showFromBarButtonItem bbi, animated:YES
  end
  
  def actionSheet(sheet, clickedButtonAtIndex:buttonIndex)
    case sheet.buttonTitleAtIndex(buttonIndex)
      when "Add All to Chart" then @set.addToCurrentMods; tableView.reloadData; dismissModalViewControllerAnimated(YES)
      when "Replace All on Chart" then @set.replaceCurrentMods; tableView.reloadData; dismissModalViewControllerAnimated(YES)
      when "Edit Set" then setEditing(YES, animated:YES)
    end
  end
  
  def empty?
    @set.mods.empty?
  end
end
