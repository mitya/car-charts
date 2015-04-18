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
    
    self.backgroundColor = KK.hex(0xF7F7F7)
    
    self.label = UILabel.alloc.initWithFrame(CGRectMake MarginL, 1, frame.width - ImageW - MarginL - MarginR*2, frame.height - 2)
    label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth
    addSubview label
    
    self.button = UIButton.buttonWithType(UIButtonTypeCustom)
    button.frame = CGRectMake frame.width - MarginR*2 - ImageW, 1, ImageW + MarginR*2, frame.height - 2
    button.setImage KK.templateImage('ci-eye'), forState:UIControlStateNormal
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    button.imageEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20)
    button.imageView.exclusiveTouch = YES
    button.showsTouchWhenHighlighted = YES
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
