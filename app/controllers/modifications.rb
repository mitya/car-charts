class Multisegment
  attr_accessor :buttons, :view
  
  def initialize
    @view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 10, 44))
    @view.backgroundColor = UIColor.clearColor    
    @buttons = []
  end
  
  def addButton(label, action)    
    button = UIButton.buttonWithType(UIButtonTypeCustom)
    button.setTitle(label, forState:UIControlStateNormal)
    button.frame = CGRectMake(5 + buttons.count * 31, 8, 30, 30)
    button.titleLabel.font = UIFont.fontWithName("Helvetica-Bold", size: 12)
    button.setBackgroundImage self.class.unselectedBackground, forState:UIControlStateNormal
    button.setBackgroundImage self.class.unselectedBackground, forState:UIControlStateHighlighted
    button.setBackgroundImage self.class.selectedBackground, forState:UIControlStateSelected
    button.setBackgroundImage self.class.selectedBackground, forState:UIControlStateSelected | UIControlStateHighlighted
    button.addTarget self, action:'buttonPressed:', forControlEvents:UIControlEventTouchDown

    view.frame = CGRectMake(view.frame.x, view.frame.y, view.frame.width + 31, view.frame.height)
    view.addSubview button
    buttons << button
  end
  
  def buttonPressed(button)
    p button
    # button.selected = !button.isSelected
  end
    
  def self.unselectedBackground
    @@unselectedBackground ||= UIImage.imageNamed("UISegmentBarMiniButton.png").resizableImageWithCapInsets(UIEdgeInsetsMake(15, 5, 15, 5))
  end

  def self.selectedBackground
    @@selectedBackground ||= UIImage.imageNamed("UISegmentBarMiniButtonHighlighted.png").resizableImageWithCapInsets(UIEdgeInsetsMake(15, 5, 15, 5))
  end
  
end

class ModificationsController < UITableViewController
  attr_accessor :model_key, :mods, :modsByBody, :filterBar

  def viewDidLoad
    super
    
    self.title = Model.model_names_branded[@model_key]
    self.mods = Model.modifications_by_model_key[@model_key].sort_by { |m| m.key }
    self.modsByBody = @mods.group_by { |m| m.body }
    self.filterBar = UIToolbar.alloc.initWithFrame(CGRectMake(0, 0, 320, 45))
    
    segmentedControl = UISegmentedControl.alloc.initWithItems(%w(AT MT))
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
    segmentedControl.addTarget(self, action:'segmentClicked:', forControlEvents:UIControlEventValueChanged)

    transmissionFilter = Multisegment.new
    transmissionFilter.addButton "MT", 'filterTransmissionByMT'
    transmissionFilter.addButton "AT", 'filterTransmissionByAT'
    
    bodyFilter = Multisegment.new
    bodyFilter.addButton "Sed", 'filterBodyBySedan'
    bodyFilter.addButton "Wag", 'filterBodyByWagon'
    bodyFilter.addButton "Hat", 'filterBodyByHatch'

    # buttons = UIView.alloc.initWithFrame(CGRectMake(0, 0, 100, 44))
    # buttons.backgroundColor = UIColor.clearColor
    # 
    # button1 = UIButton.buttonWithType(UIButtonTypeCustom)
    # button1.setTitle("MT", forState:UIControlStateNormal)
    # button1.frame = CGRectMake(5,8,30,30)
    # 
    # button2 = UIButton.buttonWithType(UIButtonTypeCustom)
    # button2.setTitle("AT", forState:UIControlStateNormal)
    # button2.frame = CGRectMake(36,8,30,30)
    # 
    # button3 = UIButton.buttonWithType(UIButtonTypeCustom)
    # button3.setTitle("CVT", forState:UIControlStateNormal)
    # button3.frame = CGRectMake(67,8,30,30)
    # 
    # [button1, button2, button3].each do |button|
    #   defaultImage = UIImage.imageNamed("UISegmentBarMiniButton.png").resizableImageWithCapInsets(UIEdgeInsetsMake(15, 5, 15, 5))
    #   selectedImage = UIImage.imageNamed("UISegmentBarMiniButtonHighlighted.png").resizableImageWithCapInsets(UIEdgeInsetsMake(15, 5, 15, 5))
    #   button.setBackgroundImage defaultImage, forState:UIControlStateNormal
    #   button.setBackgroundImage defaultImage, forState:UIControlStateHighlighted
    #   button.setBackgroundImage selectedImage, forState:UIControlStateSelected
    #   button.setBackgroundImage selectedImage, forState:UIControlStateSelected | UIControlStateHighlighted
    #   button.addTarget self, action:'buttonPressed:', forControlEvents:UIControlEventTouchDown
    #   button.titleLabel.font = UIFont.fontWithName("Helvetica-Bold", size: 12)
    #   buttons.addSubview(button)
    # end

    filterBarItems = [
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
      # UIBarButtonItem.alloc.initWithCustomView(buttons),
      UIBarButtonItem.alloc.initWithCustomView(transmissionFilter.view),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(bodyFilter.view),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(segmentedControl),
      UIBarButtonItem.alloc.initWithTitle("MT", style:UIBarButtonItemStyleBordered, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),      
    ]    
    
    self.toolbarItems = filterBarItems
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
