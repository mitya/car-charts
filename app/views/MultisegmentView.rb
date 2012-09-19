class MultisegmentView < UIView
  attr_accessor :segmentButtons, :segmentHandlers
  
  def init
    super

    dim = self.class.buttonDimensions[Hel.orientationKey]
    self.frame = CGRectMake(0, 0, dim.margin * 2, dim.barHeight)

    self.backgroundColor = UIColor.clearColor
    self.layer.borderColor = UIColor.redColor.CGColor
    self.layer.borderWidth = 0.5
    self.segmentButtons = []
    self.segmentHandlers = {}

    UIDevice.currentDevice.beginGeneratingDeviceOrientationNotifications
    NSNotificationCenter.defaultCenter.addObserver self, selector:'orientationChanged:', name:UIApplicationDidChangeStatusBarOrientationNotification, object:nil

    self
  end
  
  def addButton(label, unselected = true, &handler)
    button = UIButton.buttonWithType(UIButtonTypeCustom)
    button.setTitle(label, forState:UIControlStateNormal)
    button.titleLabel.font = UIFont.fontWithName("Helvetica-Bold", size: 12)
    button.selected = !unselected
    button.addTarget self, action:'segmentButtonDown:', forControlEvents:UIControlEventTouchDown
    button.addTarget self, action:'segmentButtonUp:', forControlEvents:UIControlEventTouchUpInside

    segmentHandlers[button] = handler
    segmentButtons << button
    addSubview button
    relayoutButtons
  end
  
  def segmentButtonDown(button)
    button.selected = !button.isSelected
  end
  
  def segmentButtonUp(button)
    handler = segmentHandlers[button]
    handler.call(!button.isSelected) if handler
  end
  
  def orientationChanged(notification)
    relayoutButtons
  end
  
  def relayoutButtons
    orientationKey = Hel.orientationKey
    dim = self.class.buttonDimensions[orientationKey]
    
    segmentButtons.each_with_index do |button, index|
      button.frame = CGRectMake(dim.margin + index * (dim.width + dim.spacing), (dim.barHeight - dim.height) / 2 + 1, dim.width, dim.height)
      
      imageKey = case
        when segmentButtons.count == 1 then :one
        when button == segmentButtons.last then :right
        when button == segmentButtons.first then :left
        else :mid
      end
      imageForDefault = self.class.buttonBackgroundFor(orientationKey, imageKey)
      imageForSelected = self.class.buttonBackgroundFor(orientationKey, "#{imageKey}Selected")
      button.setBackgroundImage imageForDefault, forState:UIControlStateNormal
      button.setBackgroundImage imageForDefault, forState:UIControlStateHighlighted
      button.setBackgroundImage imageForSelected, forState:UIControlStateSelected
      button.setBackgroundImage imageForSelected, forState:UIControlStateSelected | UIControlStateHighlighted
    end
    
    self.frame = CGRectMake(0, 0, segmentButtons.count * (dim.width + dim.spacing), dim.barHeight)
  end    
  
  class ButtonDimensions
    attr_reader :width, :height, :margin, :spacing, :barHeight
    # MARGIN - right/left margins of the button group
    # SPACING - between buttons
    def initialize(width, height, margin, spacing, barHeight)
      @width, @height, @margin, @spacing, @barHeight = width, height, margin, spacing, barHeight
    end
  end
  
  def self.buttonDimensions
    @buttonDimensions ||= { 
      portrait:  ButtonDimensions.new(39, 30, 0, 0, 44),
      landscape: ButtonDimensions.new(33.5, 24, 0, 0, 32)
    }
  end
    
  def self.buttonBackgroundFor(orientationKey, imageKey)  
    @backgroundImages ||= {}
    @backgroundImages[orientationKey] ||= loadBackgroundImagesFor(orientationKey)
    @backgroundImages[orientationKey][imageKey.to_sym]
  end

  def self.loadBackgroundImagesFor(orientationKey)  
    if orientationKey == :portrait
      basename, h, corner, border = "xui-multisegment", 10, 6, 0.5
    else
      basename, h, corner, border = "xui-multisegmentmini", 10, 5, 0.5
    end
    { 
      one: UIImage.imageNamed("#{basename}-normal-base").resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, corner)),
      oneSelected: UIImage.imageNamed("#{basename}-selected-base").resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, corner)),
      left: UIImage.imageNamed("#{basename}-normal-left").resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, border)),
      leftSelected: UIImage.imageNamed("#{basename}-selected-left").resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, border)),
      mid: UIImage.imageNamed("#{basename}-normal-mid").resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, border)),
      midSelected: UIImage.imageNamed("#{basename}-selected-mid").resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, border)),
      right: UIImage.imageNamed("#{basename}-normal-right").resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, corner)),
      rightSelected: UIImage.imageNamed("#{basename}-selected-right").resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, corner)),
    }
  end
end
