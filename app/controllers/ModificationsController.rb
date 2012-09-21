class ModificationsController < UIViewController
  attr_accessor :model, :mods, :modsByBody, :filteredMods, :tableView, :toolbar

  def initialize(model = nil)
    init
    @model = model
  end

  def viewDidLoad
    super
    
    self.title = model.name
    self.mods = model.modifications    
    
    self.tableView = UITableView.alloc.initWithFrame CGRectMake(0, 0, view.bounds.width, view.bounds.height), style: UITableViewStylePlain
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    tableView.dataSource = self
    tableView.delegate = self
    
    applyFilter
    availableFilterOptions = Modification.availableFilterOptionsFor(mods)

    @transmissionFilter = MultisegmentView.new
    @transmissionFilter.addButton("MT", Disk.filterOptions[:mt]) { |state| applyFilter(mt: state) } if availableFilterOptions[:mt]
    @transmissionFilter.addButton("AT", Disk.filterOptions[:at]) { |state| applyFilter(at: state) } if availableFilterOptions[:at]

    @bodyFilter = MultisegmentView.new
    @bodyFilter.addButton("Sed", Disk.filterOptions[:sedan]) { |state| applyFilter(sedan: state) } if availableFilterOptions[:sedan]
    @bodyFilter.addButton("Wag", Disk.filterOptions[:wagon]) { |state| applyFilter(wagon: state) } if availableFilterOptions[:wagon]
    @bodyFilter.addButton("Hat", Disk.filterOptions[:hatch]) { |state| applyFilter(hatch: state) } if availableFilterOptions[:hatch]

    @fuelFilter = MultisegmentView.new
    @fuelFilter.addButton("Gas", Disk.filterOptions[:gas]) { |state| applyFilter(gas: state) } if availableFilterOptions[:gas]
    @fuelFilter.addButton("Di", Disk.filterOptions[:diesel]) { |state| applyFilter(diesel: state) } if availableFilterOptions[:diesel]

    # UIBarButtonItem.alloc.initWithTitle("MT", style:UIBarButtonItemStyleBordered, target:nil, action:nil)
    
    self.toolbarItems = [
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@transmissionFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@bodyFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(@fuelFilter),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
    ]
    
    view.addSubview tableView
  end
  
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    true
  end
  
  def numberOfSectionsInTableView(tv)
    @modsByBody.count > 0 ? @modsByBody.count : 1
  end

  def tableView(tv, numberOfRowsInSection:section)
    return 0 if section >= @modsByBody.count
    bodyKey = modsByBody.keys[section]
    @modsByBody[bodyKey].count
  end

  def tableView(tv, titleForHeaderInSection:section)
    bodyKey = modsByBody.keys[section]
    Metadata.bodyNames[bodyKey]
  end

  def tableView(tv, titleForFooterInSection:section)
    if section == tableView.numberOfSections - 1
      hiddenModsCount = mods.count - filteredMods.count
      if @modsByBody.count == 0
        "#{hiddenModsCount} #{"model".pluralizeFor(hiddenModsCount)} available\n Relax the filter settings to view it"
      else
        hiddenModsCount > 0 ? "There are also #{hiddenModsCount} #{"model".pluralizeFor(hiddenModsCount)} hidden" : nil
      end
    end
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    bodyKey = modsByBody.keys[indexPath.section]
    mod = modsByBody[bodyKey][indexPath.row]

    cell = tv.dequeueReusableCell
    cell.textLabel.text = mod.nameWithVersion
    cell.accessoryType = Disk.currentMods.include?(mod) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    tv.deselectRowAtIndexPath(indexPath, animated:true)

    bodyKey = modsByBody.keys[indexPath.section]
    mod = modsByBody[bodyKey][indexPath.row]
    Disk.toggleModInCurrentList(mod)

    cell = tv.cellForRowAtIndexPath(indexPath)
    cell.toggleCheckmarkAccessory
  end
  
  private
  
  def applyFilter(options = {})
    Disk.filterOptions = Disk.filterOptions.merge(options) if options.any?
    Disk.filterOptions = Disk.filterOptions.dup.delete_if { |k,v| v == false }
    opts = Disk.filterOptions
    self.filteredMods = Disk.filterOptions.empty? ? mods : mods.select do |mod|
      unless opts[:at].nil? && opts[:mt].nil?
        next false if !(opts[:at] && mod.automatic? || opts[:mt] && mod.manual?)
      end

      unless opts[:sedan].nil? && opts[:hatch].nil? && opts[:wagon].nil?
        next false if !(opts[:sedan] && mod.sedan? || opts[:hatch] && mod.hatch? || opts[:wagon] && mod.wagon?)
      end

      unless opts[:gas].nil? && opts[:diesel].nil?
        next false if !(opts[:gas] && mod.gas? || opts[:diesel] && mod.diesel?)        
      end
      
      next true
    end
    self.modsByBody = filteredMods.group_by { |m| m.body }    
    tableView.reloadData
  end
end
