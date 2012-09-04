class ModificationsController < UITableViewController
  attr_accessor :model_key, :mods, :modsByBody, :filteredMods

  def viewDidLoad
    super
    
    self.title = Model.model_names_branded[@model_key]

    self.mods = Model.modifications_by_model_key[@model_key].sort_by { |m| m.key }
    applyFilter

    @transmissionFilter = MultisegmentView.new
    @transmissionFilter.addButton("MT", Model.filterOptions[:mt]) { |state| applyFilter(mt: state) }
    @transmissionFilter.addButton("AT", Model.filterOptions[:at]) { |state| applyFilter(at: state) }

    @bodyFilter = MultisegmentView.new
    @bodyFilter.addButton("Sed", Model.filterOptions[:sedan]) { |state| applyFilter(sedan: state) }
    @bodyFilter.addButton("Wag", Model.filterOptions[:wagon]) { |state| applyFilter(wagon: state) }
    @bodyFilter.addButton("Hat", Model.filterOptions[:hatch]) { |state| applyFilter(hatch: state) }

    @fuelFilter = MultisegmentView.new
    @fuelFilter.addButton("Gas", Model.filterOptions[:gas]) { |state| applyFilter(gas: state) }
    @fuelFilter.addButton("Di", Model.filterOptions[:diesel]) { |state| applyFilter(diesel: state) }

    self.toolbarItems = [
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@transmissionFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@bodyFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@fuelFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
    ]
    self.navigationController.toolbarHidden = false
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
  
  private
  
  def applyFilter(options = {})
    Model.filterOptions = Model.filterOptions.merge(options) if options.any?
    self.filteredMods = Model.filterOptions.empty? ? mods : mods.select do |mod|
      next false if Model.filterOptions[:at] && mod.automatic?
      next false if Model.filterOptions[:mt] && mod.manual?
      next false if Model.filterOptions[:sedan] && mod.sedan?
      next false if Model.filterOptions[:hatch] && mod.hatch?
      next false if Model.filterOptions[:wagon] && mod.wagon?
      next false if Model.filterOptions[:gas] && mod.gas?
      next false if Model.filterOptions[:diesel] && mod.diesel?
      next true
    end
    self.modsByBody = filteredMods.group_by { |m| m.body }    
    tableView.reloadData
  end
end
