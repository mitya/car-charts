def fsSettingsButton
  @fsSettingsButton ||= UIButton.alloc.initWithFrame(CGRectMake(view.bounds.width - 30 - 5, view.bounds.height - 35, 30, 30)).tap do |button|
    button.backgroundColor = UIColor.blackColor    
    button.setImage KK.image("bbi-gears"), forState:UIControlStateNormal
    button.alpha = 0.4
    button.setRoundedCornersWithRadius(3, width:0.5, color:UIColor.grayColor)
    button.showsTouchWhenHighlighted = true
    button.addTarget self, action:'showFullScreenSettings', forControlEvents:UIControlEventTouchUpInside
    view.addSubview(button)
  end    
end

def showFullScreenSettings
  tabBarController.setTabBarHidden(NO, animated:NO)
  tabBarController.selectedIndex = KK.app.delegate.previousTabIndex      
end
  
def returnFromFullScreenSettings
  tabBarController.setTabBarHidden(YES, animated:YES)
end

def tabBarController(tabBarController, didSelectViewController:viewController)
  if UINavigationController === viewController && ChartController === viewController.topViewController
    viewController.topViewController.returnFromFullScreenSettings if UIApplication.sharedApplication.isStatusBarHidden
  end
  @previousTabIndex = tabBarController.selectedIndex unless tabBarController.selectedIndex == 0
end
  
def previousTabIndex
  @previousTabIndex || 1
end

###

def testSQL
  db = Pointer.new(:object)
  dbPath = NSBundle.mainBundle.pathForResource("data/db-static", ofType:"sqlite")
  
  if sqlite3_open(dbPath.UTF8String, db) == SQLITE_OK
    sqlStatement = "select zmodel_title from zmod limit 20".UTF8String
    compiledStatement = Pointer.new(:object)
    if sqlite3_prepare_v2(db, sqlStatement, -1, compiledStatement, NULL) == SQLITE_OK
      while sqlite3_step(compiledStatement) == SQLITE_ROW
        p NSString.stringWithUTF8String(sqlite3_column_text(compiledStatement, 1))
      end
    end
    sqlite3_finalize(compiledStatement)
  end
  sqlite3_close(db)
end

###

segmentedControl = UISegmentedControl.alloc.initWithItems([])
segmentedControl.momentary = YES
segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
segmentedControl.insertSegmentWithImage KK.image("bbi-car"), atIndex:1, animated:NO
segmentedControl.insertSegmentWithImage KK.image("bbi-weight"), atIndex:0, animated:NO
segmentedControl.addTarget self, action:'settingsSegmentTouched:', forControlEvents:UIControlEventValueChanged
navigationItem.rightBarButtonItem = KK.customBBI(segmentedControl)



### unicode

"\u2611 \u2705 \u26AB \u26AA \u2714 \u2001"



### tableviewcell button
button = UIButton.alloc.initWithFrame CGRectMake(200, 0, 44, 44)
button.setBackgroundImage KK.capImage("bg-button-blue", 10, 9.5, 10, 9.5), forState:UIControlStateNormal
button.setImage KK.image("bbi-weight"), forState:UIControlStateNormal
button.titleLabel.font = UIFont.systemFontOfSize(11)
button.addTarget self, action:'addToModSet:', forControlEvents:UIControlEventTouchUpInside
button.tag = 1
cl.insertSubview button, atIndex:3



### tableview searchbar

def sectionIndexTitlesForTableView(tv)
  [UITableViewIndexSearch] + @brands.map { |brand| brand.name.chr }.uniq    
end
  
def tableView(tableView, sectionForSectionIndexTitle:letter, atIndex:index)
  tableView.scrollRectToVisible(@searchBar.frame, animated:NO) and return -1 if letter == UITableViewIndexSearch
  @brands.index { |brand| brand.name.chr == letter }
end  



# empty views
def presentEmptyViewIf(isEmpty)
  if isEmpty
    view.addSubview(emptyView)
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone
  else
    emptyView.removeFromSuperview if @emptyView && @emptyView.superview
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine
  end    
end
  
def emptyView
  @emptyView ||= KK.emptyView(title:"No Model Sets", subtitle:"You can use model sets to save the models you like for future reference", frame:view.bounds)
end


# tableview row moving
recentModCountBefore = Disk.recentMods.count
mod = modForIndexPath(indexPath)
mod.select!
recentModCountAfter = Disk.recentMods.count
recentModCountDelta = recentModCountAfter - recentModCountBefore
    
tableView.beginUpdates
if indexPath.section == 0 && recentModCountDelta <= 0 # 0 : one moved & one deleted, 1 : one moved, -N : N deleted & one moved
  removedRecentModsIndexPaths = KK.sequentialIndexPaths(1, recentModCountBefore + recentModCountDelta - 1, recentModCountBefore - 1)
  tableView.deleteRowsAtIndexPaths removedRecentModsIndexPaths, withRowAnimation:UITableViewRowAnimationAutomatic
end
tableView.moveRowAtIndexPath indexPath, toIndexPath:KK.indexPath(indexPath.section == 0 ? 1 : 0, 0)
tableView.endUpdates


# multicontroller segment

def initialize
  @controllers = [SelectedModListController.new, RecentModListController.new]
  self.tabBarItem = UITabBarItem.alloc.initWithTabBarSystemItem(UITabBarSystemItemRecents, tag:1)
  self.navigationItem.titleView = modeSegmentedControl
end
  
def viewDidLoad
  switchChildController
end
  
def viewWillAppear(animated)
  super
  saveButtonItem.enabled = Disk.currentMods.any?
end

def modeSegmentedControl
  @modeSegmentedControl ||= UISegmentedControl.alloc.initWithItems(@controllers.map(&:title)).tap do |segm|
    segm.segmentedControlStyle = UISegmentedControlStyleBar
    segm.addTarget self, action:'switchChildController', forControlEvents:UIControlEventValueChanged
    segm.selectedSegmentIndex = 0
  end
end
  
def switchChildController
  @controller.removeFromParentViewController if @controller
  @controller = @controllers[modeSegmentedControl.selectedSegmentIndex]
  addChildViewController(@controller)
    
  @controller.view.frame = view.bounds
  view.subviews.each { |subview| subview.removeFromSuperview }
  view.addSubview(@controller.view)    

  navigationItem.setRightBarButtonItem SelectedModListController === @controller ? saveButtonItem : nil, animated:NO
end

### events

willChangeValueForKey('currentMods')
# ...
didChangeValueForKey('currentMods')

Disk.addObserver(self, forKeyPath:"currentMods", options:NO, context:nil)
Disk.removeObserver(self, forKeyPath:"currentMods")

def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
  # ... if object == Disk && keyPath == "currentMods"
end


###

DidChangeCurrentModsNotification = 'DidChangeCurrentModsNotification'
NSNotificationCenter.defaultCenter.postNotificationName DidChangeCurrentModsNotification, object:self

NSNotificationCenter.defaultCenter.addObserver self, selector:'currentModsChanged', name:DidChangeCurrentModsNotification, object:NIL
NSNotificationCenter.defaultCenter.removeObserver self



###

NSBundle.mainBundle.objectForInfoDictionaryKey("CFBundleVersion")



### button in titleview

def init
  self.navigationItem.titleView = UIView.alloc.init
  self.navigationItem.rightBarButtonItems = [KK.flexibleSpaceBBI, viewSelectorBarItem, KK.flexibleSpaceBBI]

def viewWillAppear
  viewSelectorBarItem.title = category ? category.name : "All Models"

def viewSelectorBarItem
  @viewSelectorBarItem ||= KK.textBBI("All Models", target:self, action:'showCategories')


###

def modKeys
  @modKeys ||= begin
    fetchRequest = NSFetchRequest.fetchRequestWithEntityName('ModProxy')
    fetchRequest.predicate = NSPredicate.predicateWithFormat("self in %@", argumentArray:[modProxies.valueForKeyPath("objectID").allObjects])
    modProxyObjects = self.class.context.executeFetchRequest(fetchRequest, error:NULL)
    modProxyObjects.map(&:modKey)
  end
end

def modKeys=(keys)
  @modKeys = @mods = nil
  self.modProxies = NSSet.setWithArray( keys.map { |key| ModProxy.build modKey:key } )
end

class ModProxy < DSCoreModel
  @entityName = "ModProxy"
  @defaultSortField = 'modKey'
  @fields = [
    ['modKey', NSStringAttributeType, false]
  ]
    
  def self.initRelationships
    modToSet = NSRelationshipDescription.alloc.init
    modToSet.name = "modSet"
    modToSet.destinationEntity = ModSet.entity
    modToSet.maxCount = 1
      
    setToMod = NSRelationshipDescription.alloc.init
    setToMod.name = "modProxies"
    setToMod.destinationEntity = ModSet::ModProxy.entity
    setToMod.maxCount = -1
    setToMod.deleteRule = NSCascadeDeleteRule

    setToMod.inverseRelationship = modToSet
    modToSet.inverseRelationship = setToMod
      
    ModSet.entity.properties = ModSet.entity.properties + [setToMod]
    ModSet::ModProxy.entity.properties = ModSet::ModProxy.entity.properties + [modToSet]
  end
end

