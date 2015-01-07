class NSArray
  def dupWithToggledObject(item)
    if include?(item)
      self - [item]
    else
      self + [item]
    end
  end
  
  def tail
    self[1..-1]
  end

  def uniqueIndexBy
    index = {}
    each { |object| index[yield(object)] = object }
    index
  end
    
  def indexBy
    index = {}
    each do |object|
      key = yield(object)
      index[key] ||= []
      index[key] << object
    end
    index
  end
  
  def uniqBy
    uniqObjects = []
    uniqKeys = []
    each do |object|
      key = yield(object)
      if !uniqKeys.include?(key)
        uniqObjects << object
        uniqKeys << key
      end
    end
    uniqObjects
  end
  
  def arraySeparatedBy(separator)
    empty? ? [] : [separator] + flat_map { |obj| [obj, separator] }
  end
  
  def pluck(method)
    map { |obj| obj.send(method) }
  end
  
  def swap!(i, j)
    self[i], self[j] = self[j], self[i]
  end
  
  def blank?
    empty?
  end
  
  def sortAsIn!(referenceArray, from:startIndex)
    fixedPart = self[0...startIndex]
    referenceWithoutFixedItems = referenceArray - fixedPart
    self[startIndex..length] = referenceWithoutFixedItems
  end
end

class NSDictionary
  def symbolizeKeys
    copy = {}
    each_pair { |key, value| copy[key.to_sym] = value }
    copy
  end  
  
  def objectForIndexPath(indexPath)
    key = keys[indexPath.section]
    object = self[key][indexPath.row]
    object
  end

  def blank?
    empty?
  end
end

class NSMutableDictionary
  def symbolizeKeys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end  
end
