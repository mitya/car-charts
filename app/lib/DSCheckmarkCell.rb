class DSCheckmarkCell < UITableViewCell
  DefaultImageViewMargin = 10
  ImageViewMargin = 6
    
  def layoutSubviews
    super
    imageView.frame = CGRectMake(
      ImageViewMargin, imageView.frame.y, imageView.frame.width, imageView.frame.height
    ) if imageView
    textLabel.frame = CGRectMake(
      imageView.frame.width + ImageViewMargin * 2, textLabel.frame.y, 
      textLabel.frame.width + (DefaultImageViewMargin - ImageViewMargin) * 2, textLabel.frame.height
    ) if textLabel
    detailTextLabel.frame = CGRectMake(
      imageView.frame.width + ImageViewMargin * 2, detailTextLabel.frame.y, 
      detailTextLabel.frame.width + (DefaultImageViewMargin - ImageViewMargin) * 2, detailTextLabel.frame.height
    ) if detailTextLabel
  end
end
