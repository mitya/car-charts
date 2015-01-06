module KK::Development
  def benchmark(actionName = "Action", &block)
    return block.call unless $es_benchmarking

    startTime = Time.now
    result = block.call
    elapsed = (Time.now - startTime) * 1_000
    NSLog "TIMING #{actionName}: #{"%.3f" % elapsed}ms"
    result
  end
  
  def applyRoundCorners(view, cornerRadius = 8)
    view.layer.cornerRadius = cornerRadius
    view.layer.masksToBounds = true
  end  

  def setDevBorder(view, color = UIColor.redColor)
    view.layer.borderColor = colorize(color).CGColor
    view.layer.borderWidth = 1
    # view.layer.cornerRadius = 8
    # view.layer.masksToBounds = true    
  end    
end

KK.extend(KK::Development)
