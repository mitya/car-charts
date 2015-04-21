# Customizzes the image view size so it fit a checkmark image better
# It's about twice smaller than the default image view size
class CheckmarkCell < UITableViewCell
  ImageViewMargin = 8
    
  def initWithStyle(style, reuseIdentifier:reuseIdentifier) super
    @border = UIView.alloc.initWithFrame(CGRectMake 30, frame.height - 0.5, frame.width, 0.5)
    @border.backgroundColor = KK.hex(0xC8C7CC)
    @border.autoresizingMask = UIViewAutoresizingFlexibleWidth
    addSubview @border
    self
  end

  def layoutSubviews
    super
    
    imageViewWidthWithMargins = imageView.frame.width + ImageViewMargin * 2
    
    imageView.frame = imageView.frame.change x: ImageViewMargin if imageView
    textLabel.frame = textLabel.frame.change x: imageViewWidthWithMargins if textLabel
    detailTextLabel.frame = detailTextLabel.frame.change x: imageViewWidthWithMargins if detailTextLabel    
  end

  def toggleLeftCheckmarkAccessory(value = nil)
    value = imageView.image != CheckmarkCell.listCheckmarkImage if value == nil
    imageView.image = value ? CheckmarkCell.listCheckmarkImage : CheckmarkCell.listCheckmarkStubImage
  end

  def self.listCheckmarkImage
    @listCheckmarkImage ||= KK.templateImage("ci-checkmark")
  end
  
  def self.listCheckmarkStubImage
    @listCheckmarkStubImage ||= KK.image("ci-checkmarkStub")
  end
end
