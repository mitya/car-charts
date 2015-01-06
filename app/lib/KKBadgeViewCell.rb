# https://github.com/digdog/DDBadgeViewCell
class KKBadgeViewCell < UITableViewCell
  attr_accessor :summary, :detail, :badgeView, :badgeText, :badgeColor, :badgeHighlightedColor
  attr_accessor :textFieldEnabled, :textFieldEndEditingBlock
  
  DetailLabelRM = 5 # 20 is enought to accomodate a 1-char badge and a standard accessory view
  
  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    if super
      self.badgeView = KKBadgeView.alloc.init(contentView.bounds, self)
      badgeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      badgeView.contentMode = UIViewContentModeRedraw
      contentView.addSubview(badgeView)
    end
    self
  end
  
  def layoutSubviews
    super
    
    contentView.bringSubviewToFront(badgeView)
    contentView.bringSubviewToFront(textField)

    if detailTextLabel
      base = detailTextLabel.frame
      margin = DetailLabelRM
      margin += 15 if accessoryType != UITableViewCellAccessoryNone
      margin += 18 + 10 * badgeText.length if badgeText
      detailTextLabel.frame = CGRectMake(base.x, base.y, bounds.width - margin, base.height)
    end
  end
  
  def setEditing(editing, animated:animated)
    if textField && !showingDeleteConfirmation
      if editing
        textLabel.hidden = true
        textField.hidden = false
        animations = proc do
          textField.frame = CGRectMake(10, 11, 230, 22) # centered
          detailTextLabel.alpha = 0 if detailTextLabel          
        end
      else
        endEditing(true)
        animations = proc do
          textField.frame = CGRectMake(10, 2, 230, 22) # frame of the textLabel
          detailTextLabel.alpha = 1 if detailTextLabel          
        end
        completion = proc do |done|
          textLabel.hidden = false
          textField.hidden = true
        end        
      end      
      
      KK.animateWithDuration(animated ? 0.3 : 0, completion:completion, &animations)
    end
    
    super
  end
  
  # When uncommented those methods generate a block-passed-to-objc-method warning
  # 
  # def setSelected(selected, animated:animated)
  #   super
  #   badgeView.setNeedsDisplay
  # end
  # 
  # def setHighlighted(highlighted, animated:animated)
  #   super
  #   badgeView.setNeedsDisplay
  # end

  def badgeText=(text)
    text = text.present? && text != 0 ? text.to_s : nil
    return if @badgeText == text
    @badgeText = text
    self.setNeedsLayout
    badgeView.setNeedsDisplay
  end
  
  def textField
    return nil unless @textFieldEnabled
    @textField ||= UITextField.alloc.init.tap do |textField|
      textField.font = KK.boldFont(18)
      textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter
      textField.placeholder = "No Data"
      textField.delegate = self
      textField.returnKeyType = UIReturnKeyDone
      textField.autocorrectionType = UITextAutocorrectionTypeNo
      textField.enablesReturnKeyAutomatically = true
      contentView.addSubview textField
    end
  end
  
  def textFieldDidEndEditing(textField)
    cell = textField.superview.superview
    textFieldEndEditingBlock.call(cell)
  end
  
  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
    true
  end  
end

class KKBadgeView < UIView
  attr_accessor :cell
  
  def init(frame, cell)
    initWithFrame(frame)
    self.cell = cell
    self.backgroundColor = UIColor.clearColor
    self.layer.masksToBounds = true
    self
  end
  
  def drawRect(rect)
    context = UIGraphicsGetCurrentContext()
    
    currentSummaryColor = UIColor.blackColor
    currentDetailColor = UIColor.grayColor
    currentBadgeColor = cell.badgeColor || KK.rgbf(0.53, 0.6, 0.738)
    
    if cell.highlighted? || cell.selected?
      currentSummaryColor = UIColor.whiteColor
      currentDetailColor = UIColor.whiteColor
      currentBadgeColor = cell.badgeHighlightedColor || UIColor.whiteColor
    end
    
    badgeTextSize = cell.badgeText.to_s.sizeWithFont(UIFont.boldSystemFontOfSize(13))
    badgeViewFrame = CGRectIntegral(CGRectMake(
      rect.width - badgeTextSize.width - 24, (rect.height - badgeTextSize.height - 4) / 2, 
      badgeTextSize.width + 14, badgeTextSize.height + 4))
    
    if cell.badgeText
      CGContextSaveGState(context)
      CGContextSetFillColorWithColor(context, currentBadgeColor.CGColor)
      path = CGPathCreateMutable()
      CGPathAddArc(path, nil, 
        badgeViewFrame.x + badgeViewFrame.width - badgeViewFrame.height / 2, badgeViewFrame.y + badgeViewFrame.height / 2, 
        badgeViewFrame.height / 2, M_PI / 2, M_PI * 3 / 2, true)
      CGPathAddArc(path, nil, 
        badgeViewFrame.x + badgeViewFrame.height / 2, badgeViewFrame.y + badgeViewFrame.height / 2, 
        badgeViewFrame.height / 2, M_PI * 3 / 2, M_PI / 2, true)
      CGContextAddPath(context, path)
      CGContextDrawPath(context, KCGPathFill)
      CGContextRestoreGState(context)
    
      CGContextSaveGState(context)
      CGContextSetBlendMode(context, KCGBlendModeClear)
      cell.badgeText.drawInRect CGRectInset(badgeViewFrame, 7, 2), withFont:UIFont.boldSystemFontOfSize(13)
      CGContextRestoreGState(context)
    end
    
    if cell.summary
      currentSummaryColor.set
      cell.summary.drawAtPoint CGPointMake(10, 10), forWidth:(rect.width - badgeViewFrame.width - 24), 
        withFont:UIFont.boldSystemFontOfSize(18), lineBreakMode:UILineBreakModeTailTruncation
    end
    
    if cell.detail
      currentDetailColor.set
      cell.detail.drawAtPoint CGPointMake(10, 32), forWidth:(rect.width - badgeViewFrame.width - 24), 
        withFont:UIFont.systemFontOfSize(14), lineBreakMode:UILineBreakModeTailTruncation
    end
  end
end
