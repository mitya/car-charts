class DSMultisegmentView < UIView
  attr_accessor :segmentButtons, :segmentHandlers
  
  def initWithFrame(frame)
    super

    self.backgroundColor = UIColor.clearColor
    self.segmentButtons = []
    self.segmentHandlers = {}
      
    addGestureRecognizer UITapGestureRecognizer.alloc.initWithTarget(self, action:'tapRecognized:').tap { |r| r.delegate = self }
      
    UIDevice.currentDevice.beginGeneratingDeviceOrientationNotifications
    NSNotificationCenter.defaultCenter.addObserver self, selector:'orientationChanged:', 
        name:UIApplicationDidChangeStatusBarOrientationNotification, object:NIL

    self
  end

  def dealloc
    UIDevice.currentDevice.endGeneratingDeviceOrientationNotifications
    NSNotificationCenter.defaultCenter.removeObserver self
    super
  end
  
  def addButton(label, unselected = nil, &handler)
    button = UIButton.buttonWithType(UIButtonTypeCustom)
    button.selected = unselected
    button.setTitle(label, forState:UIControlStateNormal)
    button.setTitleShadowColor(ES.hsb(212,22,46), forState:UIControlStateSelected)
    button.setTitleShadowColor(ES.hsb(212,22,42), forState:UIControlStateNormal)
    button.titleLabel.font = UIFont.fontWithName("Helvetica-Bold", size: 12)
    button.titleLabel.shadowOffset = CGSizeMake(0, -1)
    button.addTarget self, action:'segmentButtonDown:', forControlEvents:UIControlEventTouchDown
    button.addTarget self, action:'segmentButtonUp:', forControlEvents:UIControlEventTouchUpInside

    segmentHandlers[button] = handler
    segmentButtons << button
    addSubview(button)
    
    setNeedsLayout
  end
  
  def segmentButtonDown(button)
    button.selected = !button.selected?
    reapplyButtonBackgrounds
  end
  
  def segmentButtonUp(button)
    handler = segmentHandlers[button]
    handler.call(button.selected?) if handler
  end
  
  def tapRecognized(recognizer)
    tapPoint = recognizer.locationInView(self)
    adjustedPoint = CGPointMake(tapPoint.x, bounds.height / 2)
    if button = segmentButtons.detect { |button| CGRectContainsPoint(button.frame, adjustedPoint) }
      button.sendActionsForControlEvents UIControlEventTouchDown 
      button.sendActionsForControlEvents UIControlEventTouchUpInside
    end
  end
  
  def gestureRecognizer(gestureRecognizer, shouldReceiveTouch:touch)
    touch.view.is_a?(DSMultisegmentView)
  end
  
  def orientationChanged(notification)
    setNeedsLayout
  end

  ###
  
  def active?
    segmentButtons.any? { |b| b.selected? }
  end
  
  def reapplyButtonBackgrounds
    orientationKey = ES.orientationKey
    dim = self.class.buttonDimensions[orientationKey]    
    groupIsActive = active?

    segmentButtons.each_with_index do |button, index|
      side = case
        when segmentButtons.count == 1 then :base
        when button == segmentButtons.last then :right
        when button == segmentButtons.first then :left
        else :mid
      end

      imageForDefault = self.class.buttonBackgroundFor(orientationKey, "on-#{side}")
      imageForSelected = self.class.buttonBackgroundFor(orientationKey, "off-#{side}")
      button.setBackgroundImage imageForDefault, forState:UIControlStateNormal
      button.setBackgroundImage imageForDefault, forState:UIControlStateHighlighted
      button.setBackgroundImage imageForSelected, forState:UIControlStateSelected
      button.setBackgroundImage imageForSelected, forState:UIControlStateSelected | UIControlStateHighlighted
    end    
  end
  
  def layoutSubviews
    super
    
    dim = self.class.buttonDimensions[ES.orientationKey]
    
    segmentButtons.each_with_index do |button, index|
      button.frame = CGRectMake(dim.margin + index * (dim.width + dim.spacing), (dim.barHeight - dim.height) / 2 + 1, dim.width, dim.height)
    end
    self.bounds = CGRectMake(0, 0, segmentButtons.count * (dim.width + dim.spacing), dim.barHeight)
  end
  
  def drawRect(rect)
    super
    reapplyButtonBackgrounds
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
      portrait:  ButtonDimensions.new(35, 30, 0, 0, 44),
      landscape: ButtonDimensions.new(33.5, 24, 0, 0, 32)
    }
  end
    
  def self.buttonBackgroundFor(orientationKey, imageKey)  
    @backgroundImages ||= {}
    @backgroundImages[orientationKey] ||= loadBackgroundImagesFor(orientationKey)
    @backgroundImages[orientationKey][imageKey]
  end

  def self.loadBackgroundImagesFor(orientationKey)  
    if orientationKey == :portrait
      basename, h, corner, border = "ui-multisegment", 10, 6, 0.5
    else
      basename, h, corner, border = "ui-multisegmentmini", 10, 5, 0.5
    end
    images = {}
    %w(on off).each do |state|
      images["#{state}-base"]  = UIImage.imageNamed("#{basename}-#{state}-base") .resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, corner))
      images["#{state}-left"]  = UIImage.imageNamed("#{basename}-#{state}-left") .resizableImageWithCapInsets(UIEdgeInsetsMake(h, corner, h, border))
      images["#{state}-mid"]   = UIImage.imageNamed("#{basename}-#{state}-mid")  .resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, border))
      images["#{state}-right"] = UIImage.imageNamed("#{basename}-#{state}-right").resizableImageWithCapInsets(UIEdgeInsetsMake(h, border, h, corner))
    end    
    images
  end
end
