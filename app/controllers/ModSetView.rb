class ModSetController < UITableViewController
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

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end

  ####

  def tableView(tv, numberOfRowsInSection:section)
    @set.mods.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    mod = @set.mods[indexPath.row]

    cell = tv.dequeueReusableCell(klass:DSCheckmarkCell, style:UITableViewCellStyleSubtitle) do |cell|
      cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton
    end

    cell.textLabel.text = mod.model.name
    cell.detailTextLabel.text = mod.modName(Mod::NameBodyEngineVersion)
    cell.imageView.image = mod.selected? ? UIImage.imageNamed("list_checkmark") : UIImage.imageNamed("list_checkmark_stub")
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

    cell = tv.cellForRowAtIndexPath(indexPath)
    cell.toggleLeftCheckmarkAccessory(textColor:NO)

    mod = @set.mods[indexPath.row]
    mod.select!
  end
    
  def tableView(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
    mod = @set.mods[indexPath.row]
    navigationController.pushViewController ModController.new(mod), animated:YES
  end
    
  ####
  
  def setEditing(editing, animated:animated)
    super
    navigationItem.rightBarButtonItem = isEditing ? editButtonItem : actionsButtonItem
  end
  
  def actionsButtonItem
    @actionsButtonItem ||= ES.systemBBI(UIBarButtonSystemItemAction, target:self, action:'showSetActionSheet:')
  end
  
  ####
  
  def showSetActionSheet(bbi)
    sheet = UIActionSheet.alloc.initWithTitle(NIL, delegate:self, cancelButtonTitle:"Cancel", destructiveButtonTitle:NIL, otherButtonTitles:NIL)
    sheet.addButtonWithTitle "Add Models to Chart"
    sheet.addButtonWithTitle "Replace Models on Chart"
    sheet.addButtonWithTitle "Edit Set"
    sheet.showFromBarButtonItem bbi, animated:YES
  end
  
  def actionSheet(sheet, clickedButtonAtIndex:buttonIndex)
    case sheet.buttonTitleAtIndex(buttonIndex)
      when "Replace Models on Chart" then @set.replaceCurrentMods; tableView.reloadData; dismissModalViewControllerAnimated(YES)
      when "Add Models to Chart" then @set.addToCurrentMods; tableView.reloadData; dismissModalViewControllerAnimated(YES)
      when "Edit Set" then setEditing(YES, animated:YES)
    end
  end
end
