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

    cell = tv.dequeueReusableCell klass:CheckmarkCell, style:UITableViewCellStyleSubtitle, accessoryType:UITableViewCellAccessoryDetailButton do |cell|
      cell.textLabel.adjustsFontSizeToFitWidth = YES
    end
    
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

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:YES)
    tableView.cellForRowAtIndexPath(indexPath).toggleLeftCheckmarkAccessory
    @set.mods[indexPath.row].select!
  end
    
  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
    ModViewController.showFor self, withMod: @set.mods[indexPath.row]
  end
    
  
  def setEditing(editing, animated:animated)
    super
    navigationItem.rightBarButtonItem = isEditing ? editButtonItem : actionsButtonItem
  end
  
  def actionsButtonItem
    @actionsButtonItem ||= KK.systemBBI(UIBarButtonSystemItemAction, target:self, action:'showSetActionSheet:')
  end
  
  
  ACTIONS = ["Add Models to Chart", "Replace Models on Chart", "Edit Set", "Cancel"]
  
  def showSetActionSheet(bbi)
    @sheet = UIActionSheet.alloc.initWithTitle nil, delegate:self, cancelButtonTitle:nil, destructiveButtonTitle:nil, otherButtonTitles:nil
    ACTIONS.each { |action| @sheet.addButtonWithTitle(action) }
    @sheet.cancelButtonIndex = 3
    @sheet.showFromBarButtonItem bbi, animated:YES  
  end
  
  def actionSheet(sheet, clickedButtonAtIndex:buttonIndex)
    case buttonIndex
      when 0 then @set.addToCurrentMods; tableView.reloadData
      when 1 then @set.replaceCurrentMods; tableView.reloadData
      when 2 then setEditing(YES, animated:YES)
    end
  end
  
  
  def empty?
    @set.mods.empty?
  end
end
