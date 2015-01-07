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
  
  def change(dimensions)
    result = dup
    result.origin.x = dimensions[:x] if dimensions[:x]
    result.origin.y = dimensions[:y] if dimensions[:y]
    result.size.width = dimensions[:width] if dimensions[:width]
    result.size.height = dimensions[:height] if dimensions[:height]
    result
  end  
end
