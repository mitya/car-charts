# Customizzes the image view size so it fit a checkmark image better
# It's about twice smaller than the default image view size
class CheckmarkCell < UITableViewCell
  ImageViewMargin = 8
    
  def layoutSubviews
    super
    
    imageViewWidthWithMargins = imageView.frame.width + ImageViewMargin * 2
    
    imageView.frame = imageView.frame.change x: ImageViewMargin if imageView
    textLabel.frame = textLabel.frame.change x: imageViewWidthWithMargins if textLabel
    detailTextLabel.frame = detailTextLabel.frame.change x: imageViewWidthWithMargins if detailTextLabel
  end

  def toggleLeftCheckmarkAccessory(value = nil)
    value = imageView.image != self.class.listCheckmarkImage if value == nil
    imageView.image = value ? self.class.listCheckmarkImage : self.class.listCheckmarkStubImage
  end

  def self.listCheckmarkImage
    @listCheckmarkImage ||= KK.templateImage("ci-checkmark")
  end
  
  def self.listCheckmarkStubImage
    @listCheckmarkStubImage ||= KK.image("ci-checkmarkStub")
  end
end
