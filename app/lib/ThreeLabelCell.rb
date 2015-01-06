class ThreeLabelCell < UITableViewCell
  attr_accessor :commentLabel
  
  DEFAULT_LABEL_TOP_MARGIN = 12
  
  # style must be UITableViewCellStyleValue1
  def initWithStyle(style, reuseIdentifier: reuseIdentifier)
     super
     @commentLabel = UILabel.alloc.init
     @commentLabel.textAlignment = UITextAlignmentLeft
     @commentLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize)
     @commentLabel.textColor = UIColor.grayColor
     contentView.addSubview(@commentLabel)
     
     self
   end
 
  def layoutSubviews
    super
    textLabel.frame = textLabel.frame.change(y: DEFAULT_LABEL_TOP_MARGIN)
    detailTextLabel.frame = detailTextLabel.frame.change(y: DEFAULT_LABEL_TOP_MARGIN)
    commentLabel.frame = CGRectMake(
      textLabel.frame.x, textLabel.frame.y + textLabel.frame.height + 2, 
      contentView.bounds.width - textLabel.frame.x * 2, commentLabel.font.lineHeight
    )
  end
  
  # esimated height is 2 + 14 + 2, so row height should be 44 + 18 = 62
  def self.rowHeight
    62
  end
end
