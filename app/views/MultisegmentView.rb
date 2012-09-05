class MultisegmentView < UIView
  attr_accessor :segmentButtons, :segmentHandlers
  
  SIZE = 30
  MARGIN = 0 # right/left margins of the button group
  SPACING = 0 # between buttons
  HEIGHT = 44
  
  def init
    super
    self.frame = CGRectMake(0, 0, MARGIN * 2, HEIGHT)
    self.backgroundColor = UIColor.clearColor
    self.segmentButtons = []
    self.segmentHandlers = {}
    self
  end
  
  def addButton(label, unselected = true, &handler)
    button = UIButton.buttonWithType(UIButtonTypeCustom)
    button.setTitle(label, forState:UIControlStateNormal)
    button.frame = CGRectMake(MARGIN + segmentButtons.count * (SIZE + SPACING), (HEIGHT - SIZE) / 2 + 1, SIZE, SIZE)
    button.titleLabel.font = UIFont.fontWithName("Helvetica-Bold", size: 12)
    button.selected = !unselected
    button.addTarget self, action:'segmentButtonDown:', forControlEvents:UIControlEventTouchDown
    button.addTarget self, action:'segmentButtonUp:', forControlEvents:UIControlEventTouchUpInside

    self.frame = CGRectMake(frame.x, frame.y, frame.width + SIZE + SPACING, frame.height)
    addSubview button
    segmentHandlers[button] = handler
    segmentButtons << button
    setButtonBackgrounds
  end
  
  def segmentButtonDown(button)
    button.selected = !button.isSelected
  end
  
  def segmentButtonUp(button)
    handler = segmentHandlers[button]
    handler.call(!button.isSelected) if handler
  end
  
  def setButtonBackgrounds
    segmentButtons.each do |button|
      imageKey = case
        when segmentButtons.count == 1 then :one
        when button == segmentButtons.last then :right
        when button == segmentButtons.first then :left
        else :mid
      end
      imageForDefault = self.class.buttonBackgrounds[imageKey]
      imageForSelected = self.class.buttonBackgrounds[(imageKey + "Selected").to_sym]
      button.setBackgroundImage imageForDefault, forState:UIControlStateNormal
      button.setBackgroundImage imageForDefault, forState:UIControlStateHighlighted
      button.setBackgroundImage imageForSelected, forState:UIControlStateSelected
      button.setBackgroundImage imageForSelected, forState:UIControlStateSelected | UIControlStateHighlighted
    end
  end
    
  def self.buttonBackgrounds    
    @@buttonBackgrounds ||= begin
      h, corner, border = 10, 4.5, 0.5
      {
        one: UIImage.imageNamed("OOMultisegment.png").resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, corner)),
        oneSelected: UIImage.imageNamed("OOMultisegmentSelected.png").resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, corner)),
        left: UIImage.imageNamed("OOMultisegmentLeft.png").resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, border)),
        leftSelected: UIImage.imageNamed("OOMultisegmentSelectedLeft.png").resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, border)),
        mid: UIImage.imageNamed("OOMultisegmentMid.png").resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, border)),
        midSelected: UIImage.imageNamed("OOMultisegmentSelectedMid.png").resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, border)),
        right: UIImage.imageNamed("OOMultisegmentRight.png").resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, corner)),
        rightSelected: UIImage.imageNamed("OOMultisegmentSelectedRight.png").resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, corner)),
      }    
    end
  end
end
