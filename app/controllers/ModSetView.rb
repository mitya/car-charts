class ModSetController < UITableViewController
  attr_accessor :set

  def initialize(set)
    @set = set
  end

  def viewDidLoad
    self.title = set.name
    self.navigationItem.rightBarButtonItems = [editButtonItem, ES.systemBBI(UIBarButtonSystemItemAction, target:self, action:'showSetActionSheet:')]
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
    cell = tv.dequeueReusableCell(style: UITableViewCellStyleSubtitle) { |cl| cl.selectionStyle = UITableViewCellSelectionStyleNone }
    cell.textLabel.text = mod.model.name
    cell.detailTextLabel.text = mod.modName
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
  
  ####
  
  def showSetActionSheet(bbi)
    sheet = UIActionSheet.alloc.initWithTitle("Add or replace the currently selected models with the models from this set.", 
      delegate:self, cancelButtonTitle:"Cancel", destructiveButtonTitle:NIL, otherButtonTitles:NIL)
    sheet.addButtonWithTitle "Replace Current Models"
    sheet.addButtonWithTitle "Add to Current Models"
    sheet.showFromBarButtonItem bbi, animated:YES
  end
  
  def actionSheet(sheet, clickedButtonAtIndex:buttonIndex)
    case sheet.buttonTitleAtIndex(buttonIndex)
      when "Replace Current Models" then @set.replaceCurrentMods; dismissModalViewControllerAnimated(true)
      when "Add to Current Models" then @set.addToCurrentMods; dismissModalViewControllerAnimated(true)
    end
  end
end