module KK::UI
  def capImage(imageName, top, left, bottom, right)
    KK.image(imageName).resizableImageWithCapInsets(UIEdgeInsetsMake(top, left, bottom, right))
  end
  
  def stackSpacer(view, width, height)
    spacer = UIView.alloc.initWithFrame(CGRectMake(0, 0, width, height))
    spacer.autoresizingMask = UIViewAutoresizingFlexibleWidth
    view.addSubview(spacer)
    spacer
  end
  
  def stackViews(views)
    y = views.first.frame.y
    views.each do |view|
      view.frame = CGRectMake(view.bounds.x, y, view.bounds.width, view.bounds.height)
      y += view.bounds.height
    end
  end

  def emptyView(options)
    title = options[:title]
    subtitle = options[:subtitle]
    frame = options[:frame]
    
    view = UIView.alloc.init
    view.frame = CGRectMake(frame.x + 15, 0, frame.width - 30, frame.height)
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight

    titleFont = UIFont.boldSystemFontOfSize(17)
    titleHeight = title.sizeWithFont(titleFont, constrainedToSize:view.bounds.size).height
    titleLabel = UILabel.alloc.initWithFrame(CGRectMake(0, ZERO, view.bounds.width, titleHeight))
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
    titleLabel.text = title
    titleLabel.textAlignment = UITextAlignmentCenter
    titleLabel.lineBreakMode = UILineBreakModeWordWrap
    titleLabel.textColor = UIColor.grayColor
    titleLabel.backgroundColor = UIColor.clearColor
    titleLabel.font = titleFont
    titleLabel.numberOfLines = 0

    if subtitle
      subtitleFont = UIFont.systemFontOfSize(12)
      subtitleHeight = subtitle.sizeWithFont(subtitleFont, constrainedToSize:view.bounds.size).height
      subtitleLabel = UILabel.alloc.initWithFrame(CGRectMake(0, ZERO, view.bounds.width, subtitleHeight))
      subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
      subtitleLabel.text = subtitle
      subtitleLabel.textAlignment = UITextAlignmentCenter
      subtitleLabel.lineBreakMode = UILineBreakModeWordWrap
      subtitleLabel.textColor = UIColor.grayColor
      subtitleLabel.backgroundColor = UIColor.clearColor
      subtitleLabel.font = subtitleFont
      subtitleLabel.numberOfLines = 0
    end
    
    KK.stackViews [KK.stackSpacer(view, view.frame.width, 70), titleLabel, KK.stackSpacer(view, view.frame.width, 8), subtitleLabel].compact
    
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel) if subtitleLabel
    
    view
  end
  
  def emptyViewLabel(text, bounds)
    label = UILabel.alloc.initWithFrame(bounds)
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    label.text = text
    label.textAlignment = UITextAlignmentCenter
    label.textColor = UIColor.grayColor
    label.backgroundColor = UIColor.clearColor
    label.font = UIFont.boldSystemFontOfSize(17)
    label.numberOfLines = 0
    label
  end

  def tableViewFooterLabel(text = "")
    font = UIFont.systemFontOfSize(15)
    textHeight = text.sizeWithFont(font).height
    topMargin = 6

    view = UIView.alloc.initWithFrame [[0, 0], [ZERO, textHeight + topMargin]]
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth
    label = UILabel.alloc.initWithFrame([[0, topMargin], [view.frame.width, textHeight]]).tap do |label|
      label.text = text
      label.backgroundColor = UIColor.clearColor
      label.font = font
      label.textColor = KK.tableViewFooterColor
      label.shadowColor = UIColor.colorWithWhite(1, alpha:1)
      label.shadowOffset = CGSizeMake(0, 1)
      label.textAlignment = UITextAlignmentCenter
      label.autoresizingMask = UIViewAutoresizingFlexibleWidth
      view.addSubview(label)        
    end
    
    view
  end

  def tableViewGrayBackground
    screen = UIScreen.mainScreen.applicationFrame
    topview = UIView.alloc.initWithFrame(CGRectMake(0, -screen.height, screen.width, screen.height))
    topview.backgroundColor = KK.rgb(226, 231, 238)
    topview.autoresizingMask = UIViewAutoresizingFlexibleWidth
    topview
  end  

  def customBBI(view = nil)
    view ||= yield
    UIBarButtonItem.alloc.initWithCustomView(view)
  end
  
  def systemBBI(style)
    systemBBI(style, target:NIL, action:NIL)
  end

  def systemBBI(style, target:target, action:action)
    UIBarButtonItem.alloc.initWithBarButtonSystemItem(style, target:target, action:action)
  end

  def imageBBI(imageName, target:target, action:action)
    UIBarButtonItem.alloc.initWithImage(KK.image(imageName), style:UIBarButtonItemStylePlain, target:target, action:action)      
  end

  def textBBI(text)
    textBBI(text, style:UIBarButtonItemStylePlain, target:NIL, action:NIL)
  end

  def textBBI(text, target:target, action:action)
    textBBI(text, style:UIBarButtonItemStylePlain, target:target, action:action)
  end

  def textBBI(text, style:style, target:target, action:action)
    UIBarButtonItem.alloc.initWithTitle(text, style:style, target:target, action:action)
  end
  
  def flexibleSpaceBBI
    KK.systemBBI(UIBarButtonSystemItemFlexibleSpace)
  end

  def fixedSpaceBBI(width = nil)
    KK.fixedSpaceBBIWithWidth(nil)
  end

  def fixedSpaceBBIWithWidth(width = nil)
    KK.systemBBI(UIBarButtonSystemItemFixedSpace, target:nil, action:nil).tap { |bbi| bbi.width = width if width }
  end

  def plainBBI(imageName, target:target, action:action, options:options)
    options = NSDictionary.dictionary if options == nil

    button = UIButton.buttonWithType(UIButtonTypeCustom)
    button.frame = [[0, 0], options[:size] || [20, 20]]
    button.setImage KK.image(imageName), forState:UIControlStateNormal
    button.setImage KK.image(options[:selected]), forState:UIControlStateSelected if options[:selected]
    button.showsTouchWhenHighlighted = YES
    button.addTarget target, action:action, forControlEvents:UIControlEventTouchUpInside

    customBBI(button)      
  end

  def segmentedControl(items)
    segmentedControl = UISegmentedControl.alloc.initWithItems(items)
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar
    segmentedControl
  end    
end

KK.extend(KK::UI)
