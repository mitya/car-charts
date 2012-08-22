class ModificationsController < UITableViewController
  attr_accessor :model_key, :mods, :modsByBody, :filterBar

  def viewDidLoad
    super
    self.title = "Modifications"
    @mods = Model.modifications_by_model_key[@model_key].sort_by { |m| m.key }
    @modsByBody = @mods.group_by { |m| m.body }

    self.filterBar = UIToolbar.alloc.initWithFrame(CGRectMake(0, 0, 320, 45))
    
    segmentedControl = UISegmentedControl.alloc.initWithItems(%w(Sd Hb Wg))
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
    segmentedControl.momentary = true
    # segmentedControl.addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];

    # sedan wagon 3-door 5-door

    filterBarItems = [
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(segmentedControl),
      UIBarButtonItem.alloc.initWithTitle("MT", style:UIBarButtonItemStyleBordered, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithTitle("AT", style:UIBarButtonItemStyleDone, target:nil, action:nil),      
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),      
    ]
    
    # filterBar.items = filterBarItems
    self.toolbarItems = filterBarItems
    self.navigationController.toolbarHidden = false
    # filterBar.sizeToFit
    # tableView.tableHeaderView = filterBar
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
