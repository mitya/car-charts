class ModificationsController < UITableViewController
  attr_accessor :model_key, :mods, :modsByBody, :filterBar

  def viewDidLoad
    super
    self.title = Model.model_names_branded[@model_key]
    @mods = Model.modifications_by_model_key[@model_key].sort_by { |m| m.key }
    @modsByBody = @mods.group_by { |m| m.body }

    self.filterBar = UIToolbar.alloc.initWithFrame(CGRectMake(0, 0, 320, 45))
    
    segmentedControl = UISegmentedControl.alloc.initWithItems(%w(AT MT))
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
    segmentedControl.addTarget(self, action:'segmentClicked:', forControlEvents:UIControlEventValueChanged)

    buttons = UIView.alloc.initWithFrame(CGRectMake(0, 0, 120, 44))
    buttons.backgroundColor = UIColor.clearColor
    buttons.layer.borderColor = UIColor.redColor.CGColor
    buttons.layer.borderWidth = 1
    
    button1 = UIButton.buttonWithType(UIButtonTypeCustom)
    button1.setTitle("MT", forState:UIControlStateNormal)
    button1.frame = CGRectMake(5,6,30,30)
    button1.titleLabel.font = UIFont.fontWithName("Helvetica-Bold", size: 12)

    # button1.backgroundColor = UIColor.brownColor
    # button1.layer.cornerRadius = 8
    # button1.layer.masksToBounds = true
    # button1.layer.borderWidth = 1
    # button1.layer.borderColor = Color.rgbi(128, 128, 128).CGColor

    corners = UIRectCornerTopLeft | UIRectCornerBottomLeft
    rect = button1.bounds
    buttonPath = UIBezierPath.bezierPathWithRoundedRect(rect, byRoundingCorners:corners, cornerRadii:CGSizeMake(8, 8))

    maskLayer = CAShapeLayer.layer
    maskLayer.frame = rect
    maskLayer.path = buttonPath.CGPath
    
    borderLayer = CAShapeLayer.layer
    borderLayer.frame = rect
    borderLayer.path = buttonPath.CGPath
    borderLayer.fillColor = UIColor.clearColor.CGColor
    borderLayer.strokeColor = Color.rgbi(55, 66, 77).CGColor
    borderLayer.lineWidth = 2
    
    gradientLayer = CAGradientLayer.alloc.init
    gradientLayer.bounds = rect
    gradientLayer.position = CGPointMake(rect.width / 2, rect.height / 2)
    # gradientLayer.setColors([Color.rgbi(138, 161, 191).CGColor, Color.rgbi(74, 108, 155).CGColor])
    gradientLayer.setColors([Color.rgbi(160, 174, 194).CGColor, Color.rgbi(126, 148, 176).CGColor])

    button1.layer.mask = maskLayer
    button1.layer.insertSublayer(gradientLayer, atIndex:0)
    button1.layer.insertSublayer(borderLayer, atIndex:1)

    filterBarItems = [
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(buttons),
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFixedSpace, target:nil, action:nil),
      UIBarButtonItem.alloc.initWithCustomView(segmentedControl),
      # UIBarButtonItem.alloc.initWithTitle("MT", style:UIBarButtonItemStyleBordered, target:nil, action:nil),
      # UIBarButtonItem.alloc.initWithTitle("AT", style:UIBarButtonItemStyleDone, target:nil, action:nil),      
      UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil),      
    ]
    
    # button1.addTarget(self, action:'buttonPressed:', forControlEvents:UIControlEventTouchUpInside)
    
    buttons.addSubview(button1)
    
    # filterBar.items = filterBarItems
    self.toolbarItems = filterBarItems
    self.navigationController.toolbarHidden = false
    # tableView.tableHeaderView = filterBar
    # filterBar.sizeToFit
  end
  
  def segmentClicked(segment)
    p segment
    p segment.selectedSegmentIndex
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
