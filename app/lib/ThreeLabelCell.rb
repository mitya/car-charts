# http://blog.willrax.com/custom-uitableviewcells-in-rubymotion/
class ThreeLabelCell < UITableViewCell
  attr_accessor :commentLabel, :hideDetailsWhenEditing
  
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
      textLabel.frame.x, textLabel.frame.y + textLabel.frame.height + 4,
      contentView.bounds.width - textLabel.frame.x, commentLabel.font.lineHeight
    )
  end
  
  def setEditing(editing, animated:animated)
    detailTextLabel.setHidden editing, animated:animated if hideDetailsWhenEditing
    super
  end
    
  # esimated height is 2 + 14 + 2, so row height should be 44 + 18 = 62
  def self.rowHeight
    64
  end
end
