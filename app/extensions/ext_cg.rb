class CGPoint
  def inspect
    "{#{x}, #{y}}"
  end  
end

class CGRect
  def x
    origin.x
  end

  def y
    origin.y
  end

  def width
    size.width
  end

  def height
    size.height
  end
  
  def rectWithHorizMargins(margin)
    CGRectMake(x + margin, y, width - margin * 2, height)
  end
  
  def inspect
    "{#{x}, #{y}, #{width}, #{height}}"
  end
end
