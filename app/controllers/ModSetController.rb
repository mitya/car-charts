class ModSetController < UITableViewController
  attr_accessor :set

  def initialize(set)
    @set = set
  end

  def viewDidLoad
    super
    self.title = set.name
    navigationItem.rightBarButtonItem = Hel.systemBBI(UIBarButtonSystemItemAction, target:self, action:'showSetActionsSheet:')
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
    cell.detailTextLabel.text = mod.mod_name
    cell
  end
  
  ####
  
  def replaceCurrent
    @set.replaceCurrentMods
  end
  
  def addToCurrent
    @set.addToCurrentMods
  end
  
  def showSetActionsSheet(bbi)
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
