class ModListController < UIViewController
  attr_accessor :model, :mods, :modsByBody, :filteredMods, :tableView, :toolbar

  def initialize(model = nil)
    self.model = model
    self.mods = model.mods
    self.title = model.nameWithApostrophe
    navigationItem.backBarButtonItem = KK.textBBI("Versions")                    
    navigationItem.rightBarButtonItem = KK.imageBBI("bi-filter", target:self, action:'showFilterPane')
    Disk.addObserver(self, forKeyPath:"filterOptions", options:false, context:nil)
  end
  
  def dealloc
    Disk.removeObserver(self, forKeyPath:"filterOptions")    
  end
  
  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    __assert keyPath == 'filterOptions'
    applyFilter if isViewVisible
  end
  

  def viewDidLoad
    self.tableView = setupInnerTableViewWithStyle(UITableViewStylePlain)
  end
  
  def viewWillAppear(animated)
    super
    applyFilter
  end
  

  def numberOfSectionsInTableView(tv)
    @modsByBody.count > 0 ? @modsByBody.count : 1
  end

  def tableView(tv, numberOfRowsInSection:section)
    return 0 if section >= @modsByBody.count
    @modsByBody[ modsByBody.keys[section] ].count
  end

  def tableView(tv, titleForHeaderInSection:section)
    Metadata.parameterTranslations['body'][ modsByBody.keys[section] ]
  end

  def tableView(tv, titleForFooterInSection:section)
    if section == tableView.numberOfSections - 1
      hiddenModsCount = mods.count - filteredMods.count
      if @modsByBody.count == 0 && !mods.empty?
        return "All #{hiddenModsCount} #{"model".pluralizeFor(hiddenModsCount)} are filtered out"
      else
        return hiddenModsCount > 0 ? "There are also #{hiddenModsCount} #{"model".pluralizeFor(hiddenModsCount)} hidden" : nil
      end
    end
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    mod = modsByBody.objectForIndexPath(indexPath)
    modIsSelected = mod.selected?

    cell = tv.dequeueReusableCell klass:CheckmarkCell, accessoryType:UITableViewCellAccessoryDetailButton
    cell.toggleLeftCheckmarkAccessory(modIsSelected)
    cell.textLabel.text = mod.modName(Mod::NameEngineVersion)
    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    tv.deselectRowAtIndexPath(indexPath, animated:YES)
    cell = tv.cellForRowAtIndexPath(indexPath)
    cell.toggleLeftCheckmarkAccessory

    mod = modsByBody.objectForIndexPath(indexPath)
    mod.select!
  end
  
  def tableView(tv, accessoryButtonTappedForRowWithIndexPath:indexPath)
    ModViewController.showFor self, withMod: modsByBody.objectForIndexPath(indexPath)
  end
  
  
  def addToModSet(button)
    indexPath = tableView.indexPathForCell(button.superview)
    mod = modsByBody.objectForIndexPath(indexPath)
    # nothing for now
  end
  

  def applyFilter(options = {})
    opts = Disk.filterOptions
    self.filteredMods = opts.empty? ? mods : mods.select do |mod|
      next false if opts[:at] == false && mod.automatic?
      next false if opts[:mt] == false && mod.manual?
      next false if opts[:sedan] == false && mod.sedan?
      next false if opts[:hatch] == false && mod.hatch?
      next false if opts[:wagon] == false && mod.wagon?
      next false if opts[:gas] == false && mod.gas?
      next false if opts[:diesel] == false && mod.diesel?
      next true
    end
    self.modsByBody = filteredMods.group_by { |m| m.body }
    tableView.reloadData
  end
    
  def showFilterPane
    @filterController ||= ModListFilterController.new
    if KK.iphone?
      presentNavigationController @filterController, presentationStyle:UIModalPresentationCurrentContext
    else
      @filterController.popover = presentPopoverController @filterController, fromBarItem:navigationItem.rightBarButtonItem
    end
  end
end
