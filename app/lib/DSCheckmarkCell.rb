# Customizzes the image view size so it fit a checkmark image better
# It's about twice smaller than the default image view size
class DSCheckmarkCell < UITableViewCell
  ImageViewMargin = 8
    
  def layoutSubviews
    super
    
    imageViewWidthWithMargins = imageView.frame.width + ImageViewMargin * 2
    
    imageView.frame = imageView.frame.change x: ImageViewMargin if imageView
    textLabel.frame = textLabel.frame.change x: imageViewWidthWithMargins if textLabel
    detailTextLabel.frame = detailTextLabel.frame.change x: imageViewWidthWithMargins if detailTextLabel
  end
end
