class ModificationsController < UITableViewController
  attr_accessor :model_key, :mods, :modsByBody

  def viewDidLoad
    super
    
    self.title = Model.model_names_branded[@model_key]
    self.mods = Model.modifications_by_model_key[@model_key].sort_by { |m| m.key }
    self.modsByBody = @mods.group_by { |m| m.body }
    
    @transmissionFilter = MultisegmentView.new
    @transmissionFilter.addButton "MT", 'filterTransmissionByMT'
    @transmissionFilter.addButton "AT", 'filterTransmissionByAT'

    @bodyFilter = MultisegmentView.new
    @bodyFilter.addButton "Sed", 'filterBodyBySedan'
    @bodyFilter.addButton "Wag", 'filterBodyByWagon'
    @bodyFilter.addButton "Hat", 'filterBodyByHatch'

    self.toolbarItems = [
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@transmissionFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@bodyFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
    ]
    self.navigationController.toolbarHidden = false
  end
  
  def buttonPressed(button)
    button.selected = !button.isSelected
  end
  
  def segmentClicked(segment)
  end

  def numberOfSectionsInTableView(tview)
    @modsByBody.count
  end

  def tableView(tv, numberOfRowsInSection:section)
    bodyKey = modsByBody.keys[section]
    @modsByBody[bodyKey].count
  end

  def tableView(tview, titleForHeaderInSection:section)
    bodyKey = modsByBody.keys[section]
    Static.body_names[bodyKey]
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    bodyKey = modsByBody.keys[indexPath.section]
    mod = modsByBody[bodyKey][indexPath.row]

    cell = table.dequeueReusableCell
    cell.textLabel.text = mod.nameWithVersion
    cell.accessoryType = Model.current_mod_keys.include?(mod.key) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    bodyKey = modsByBody.keys[indexPath.section]
    mod = modsByBody[bodyKey][indexPath.row]

    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmark
    Model.toggleModWithKey(mod.key)
  end
end
