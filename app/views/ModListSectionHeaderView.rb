class ModListSectionHeaderView < UIView
  attr_accessor :label, :button
  attr_accessor :title, :sectionIndex, :buttonAction, :buttonTarget
  
  ImageW = 26.5
  ImageH = 16
  MarginL = 13
  MarginR = 13.5
  MarginM = 5

  def initWithFrame(frame)
    super
    
    self.backgroundColor = KK.hex(0xF5F5F5)
    
    self.label = UILabel.alloc.initWithFrame(CGRectMake MarginL, 1, frame.width - ImageW - MarginL - MarginR*2, frame.height - 2)
    label.font = UIFont.boldSystemFontOfSize(17)
    # label.backgroundColor = UIColor.greenColor
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth
    addSubview label
    
    self.button = UIButton.buttonWithType(UIButtonTypeCustom)
    # button.frame = CGRectMake frame.width - MarginR - ImageW, (frame.height - ImageH) / 2, ImageW, ImageH
    # button.frame = CGRectMake frame.width - MarginR - ImageW, 1, ImageW, frame.height - 2
    button.frame = CGRectMake frame.width - MarginR*2 - ImageW, 1, ImageW + MarginR*2, frame.height - 2
    button.setImage KK.templateImage('ci-eye'), forState:UIControlStateNormal
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    button.imageEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20)
    button.imageView.exclusiveTouch = YES
    # button.imageView.showsTouchWhenHighlighted = YES
    # button.backgroundColor = UIColor.yellowColor
    button.addTarget self, action:'buttonTouch', forControlEvents:UIControlEventTouchUpInside
    addSubview(button)
    
    self
  end
  
  def title=(text)
    label.text = text
  end
  
  
  def buttonTouch
    if buttonTarget && buttonAction
      buttonTarget.send(buttonAction, sectionIndex)
    end
  end
  
  def self.sectionHeight
    44
  end
end
