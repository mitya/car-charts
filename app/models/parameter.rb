class Parameter
  attr_accessor :key, :name

  def initialize(key, name)
    @key, @name = key.to_sym, name
  end

  def unitKey
    Metadata.parameterUnits[key]
  end
  
  def unitName
    Metadata.parameterUnitNames[unitKey]
  end  
  
  def long?
    LongParameters.containsObject(key)
  end
  
  def appliesToBody?
    BodyParameters.containsObject(key)
  end
  
  def selected?
    Disk.currentParameters.include?(self)
  end
  
  def select!
    Disk.currentParameters = Disk.currentParameters.dupWithToggledObject(self)
  end
  
  def formattedValue(value)
    return "" if value == nil
    text = case 
      when key == :produced_since || key == :produced_till
        year, month = value.to_i.divmod(100)
        month == 0 ? year : "#{year}.#{month.to_s.rjust(2, '0')}"
      when Float === value
        "%.1f" % value
      else 
        value
    end
    "#{text} #{unitName}".strip
  end
  
  def inspect
    "{#{key}}"
  end
  
  class << self
    attr_reader :all

    def parameterForKey(key)
      @index[key]
    end
    
    def load
      @all = Metadata.parameterNames.map { |key, name| new(key, name) }
      @index = @all.uniqueIndexBy(&:key)
    end
    
    def groupKeys
      Metadata[:parameterGroups]
    end
    
    def nameForGroup(groupKey)
      Metadata[:parameterGroupsData][groupKey][0]
    end
    
    def parametersForGroup(groupKey)
      Metadata[:parameterGroupsData][groupKey][1].map { |k| parameterForKey(k) }
    end
  end
  
  BodyParameters = NSSet.setWithArray([:length, :width, :height])
  LongParameters = NSSet.setWithArray([:consumption_city, :consumption_highway, :consumption_mixed])
end
