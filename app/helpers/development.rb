module KK::Development
  def benchmark(actionName = "Action", &block)
    return yield unless CC_BENCHMARKING
    startTime = Time.now
    result = yield
    elapsed = (Time.now - startTime) * 1_000
    KK.debug "TIMING #{actionName}: #{"%.3f" % elapsed}ms"
    result
  end
  
  def applyRoundCorners(view, cornerRadius = 8)
    view.layer.cornerRadius = cornerRadius
    view.layer.masksToBounds = true
  end  

  def set_border(view, color = UIColor.redColor)
    view.layer.borderColor = colorize(color).CGColor
    view.layer.borderWidth = 1
    # view.layer.cornerRadius = 8
    # view.layer.masksToBounds = true    
  end    
end

KK.extend(KK::Development)
