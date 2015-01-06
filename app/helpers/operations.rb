module KK::Operations
  def loadJSON(file, type)
    path = NSBundle.mainBundle.pathForResource(file, ofType:type)
    error = Pointer.new(:object)
    NSJSONSerialization.JSONObjectWithData(NSData.dataWithContentsOfFile(path), options:0, error:error)
  end    
end

KK.extend(KK::Operations)