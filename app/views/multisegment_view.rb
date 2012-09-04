class MultisegmentView < UIView
  attr_accessor :segmentButtons, :segmentHandlers
  
  SIZE = 30
  MARGIN = 2 # right/left margins of the button group
  SPACING = 1 # between buttons
  HEIGHT = 44
  
  def init
    super
    self.frame = CGRectMake(0, 0, MARGIN * 2, HEIGHT)
    self.backgroundColor = UIColor.clearColor
    self.segmentButtons = []
    self.segmentHandlers = {}
    self
  end
  
  def addButton(label, action = nil, &handler)
    button = UIButton.buttonWithType(UIButtonTypeCustom)
    button.setTitle(label, forState:UIControlStateNormal)
    button.frame = CGRectMake(MARGIN + segmentButtons.count * (SIZE + SPACING), (HEIGHT - SIZE) / 2 + 1, SIZE, SIZE)
    button.titleLabel.font = UIFont.fontWithName("Helvetica-Bold", size: 12)
    button.setBackgroundImage self.class.unselectedBackground, forState:UIControlStateNormal
    button.setBackgroundImage self.class.unselectedBackground, forState:UIControlStateHighlighted
    button.setBackgroundImage self.class.selectedBackground, forState:UIControlStateSelected
    button.setBackgroundImage self.class.selectedBackground, forState:UIControlStateSelected | UIControlStateHighlighted
    button.selected = true
    button.addTarget self, action:'segmentButtonDown:', forControlEvents:UIControlEventTouchDown
    button.addTarget self, action:'segmentButtonUp:', forControlEvents:UIControlEventTouchUpInside

    self.frame = CGRectMake(frame.x, frame.y, frame.width + SIZE + SPACING, frame.height)
    addSubview button
    segmentHandlers[button] = handler
    segmentButtons << button
  end
  
  def segmentButtonDown(button)
    button.selected = !button.isSelected
  end
  
  def segmentButtonUp(button)
    handler = segmentHandlers[button]
    handler.call(!button.isSelected) if handler
  end
    
  def self.unselectedBackground
    @@unselectedBackground ||= UIImage.imageNamed("UISegmentBarMiniButton.png").resizableImageWithCapInsets(UIEdgeInsetsMake(15, 5, 15, 5))
  end

  def self.selectedBackground
    @@selectedBackground ||= UIImage.imageNamed("UISegmentBarMiniButtonHighlighted.png").resizableImageWithCapInsets(UIEdgeInsetsMake(15, 5, 15, 5))
  end
end
