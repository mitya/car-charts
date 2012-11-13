class SelectedModsSegmentController < UIViewController
  def initialize
    @controllers = [SelectedModsController.new, RecentModsController.new]
    self.tabBarItem = UITabBarItem.alloc.initWithTabBarSystemItem(UITabBarSystemItemRecents, tag:1)
    self.navigationItem.titleView = modeSegmentedControl
  end
  
  def viewDidLoad
    switchChildController
  end
  
  def viewWillAppear(_)
    super
    saveButtonItem.enabled = Disk.currentMods.any?
  end

  ###
  
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

    navigationItem.setRightBarButtonItem SelectedModsController === @controller ? saveButtonItem : nil, animated:NO
  end

  ###

  def saveButtonItem
    @saveButtonItem ||= ES.textBBI("Save", target:self, action:'saveAsSet')
  end
  
  def saveAsSet
    selector = SelectModSetController.new
    selectorNav = UINavigationController.alloc.initWithRootViewController(selector)
    selectorNav.navigationBar.barStyle = UIBarStyleBlack
    if iphone?
      selector.closeProc = -> { dismissModalViewControllerAnimated true, completion:NIL }
      presentViewController selectorNav, animated:YES, completion:NIL
    else            
      selector.closeProc = -> { @popover.dismissPopoverAnimated(YES) }
      @popover = UIPopoverController.alloc.initWithContentViewController(selectorNav)
      @popover.presentPopoverFromBarButtonItem navigationItem.rightBarButtonItem, permittedArrowDirections:UIPopoverArrowDirectionAny, animated:YES
    end
  end
end
