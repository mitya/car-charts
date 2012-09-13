class ModificationsController < UIViewController
  attr_accessor :model, :mods, :modsByBody, :filteredMods, :tableView, :toolbar

  def viewDidLoad
    super
    
    self.title = model.name
    self.mods = model.modifications    
    
    self.tableView = UITableView.alloc.initWithFrame(CGRectMake(0,44,320,480), style: UITableViewStylePlain)
    tableView.dataSource = self
    tableView.delegate = self
    
    applyFilter
    availableFilterOptions = Modification.availableFilterOptionsFor(mods)

    @transmissionFilter = MultisegmentView.new
    @transmissionFilter.addButton("MT", Model.filterOptions[:mt]) { |state| applyFilter(mt: state) } if availableFilterOptions[:mt]
    @transmissionFilter.addButton("AT", Model.filterOptions[:at]) { |state| applyFilter(at: state) } if availableFilterOptions[:at]

    @bodyFilter = MultisegmentView.new
    @bodyFilter.addButton("Sed", Model.filterOptions[:sedan]) { |state| applyFilter(sedan: state) } if availableFilterOptions[:sedan]
    @bodyFilter.addButton("Wag", Model.filterOptions[:wagon]) { |state| applyFilter(wagon: state) } if availableFilterOptions[:wagon]
    @bodyFilter.addButton("Hat", Model.filterOptions[:hatch]) { |state| applyFilter(hatch: state) } if availableFilterOptions[:hatch]

    @fuelFilter = MultisegmentView.new
    @fuelFilter.addButton("Gas", Model.filterOptions[:gas]) { |state| applyFilter(gas: state) } if availableFilterOptions[:gas]
    @fuelFilter.addButton("Di", Model.filterOptions[:diesel]) { |state| applyFilter(diesel: state) } if availableFilterOptions[:diesel]
    
    self.toolbar = UIToolbar.alloc.initWithFrame(CGRectMake(0,0,320, 44))
    toolbar.items = [
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@transmissionFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@bodyFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@fuelFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),      
    ]
    toolbar.sizeToFit
    toolbar.setBackgroundImage(UIImage.imageNamed("bg-toolbar-under"), forToolbarPosition:UIToolbarPositionAny, barMetrics:UIBarMetricsDefault)
    
    view.addSubview(toolbar)
    view.addSubview(tableView)    
  end
  
  def numberOfSectionsInTableView(tview)
    @modsByBody.count > 0 ? @modsByBody.count : 1
  end

  def tableView(tv, numberOfRowsInSection:section)
    return 0 if section >= @modsByBody.count
    bodyKey = modsByBody.keys[section]
    @modsByBody[bodyKey].count
  end

  def tableView(tview, titleForHeaderInSection:section)
    bodyKey = modsByBody.keys[section]
    Metadata.bodyNames[bodyKey]
  end

  def tableView(tview, titleForFooterInSection:section)
    if section == tableView.numberOfSections - 1
      hiddenModsCount = mods.count - filteredMods.count
      if @modsByBody.count == 0
        "#{hiddenModsCount} #{"model".pluralizeFor(hiddenModsCount)} available\n Relax the filter settings to view it"
      else
        hiddenModsCount > 0 ? "There are also #{hiddenModsCount} #{"model".pluralizeFor(hiddenModsCount)} hidden" : nil
      end
    end
  end

  def tableView(table, cellForRowAtIndexPath:indexPath)
    bodyKey = modsByBody.keys[indexPath.section]
    mod = modsByBody[bodyKey][indexPath.row]

    cell = table.dequeueReusableCell
    cell.textLabel.text = mod.nameWithVersion
    cell.accessoryType = Model.currentMods.include?(mod) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView(table, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)

    bodyKey = modsByBody.keys[indexPath.section]
    mod = modsByBody[bodyKey][indexPath.row]
    Model.toggleModInCurrentList(mod)

    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmarkAccessory
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