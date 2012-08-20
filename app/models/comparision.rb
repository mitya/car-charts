class Comparision
  attr_accessor :mods, :params
  
  def initialize(mods, params)
    @mods = mods
    @params = params
  end
  
  def values_for(param)
    @values ||= {}
    @values[param] ||= mods.map { |mod| mod[param] }.compact
  end
  
  def max_value_for(param)
    @max_values ||= {}
    @max_values[param] ||= values_for(param).max
  end

  def min_value_for(param)
    # @min_values ||= {}
    # @min_values[param] ||= values_for(param).min
    0
  end
  
  def range_for(param)
    @ranges ||= {}
    @ranges[param] ||= max_value_for(param) - min_value_for(param)    
  end
  
  def items
    @items ||= (0...mods.count).map { |index| ComparisionItem.new(self, index) }
  end
  
  def title
    return "Select some cars..." if params.count == 0
    return Static.parameter_names[params.first.to_sym] if params.count == 1
    "#{Static.parameter_names[params.first.to_sym]} +#{params.count - 1}"
    # params.map { |p| Static.parameter_names[p.to_sym] }.join(' - ')
  end
end

class ComparisionItem
  attr_accessor :index, :comparision
  
  def initialize(comparision, index)
    @comparision, @index = comparision, index
  end
  
  def mods
    @comparision.mods
  end
  
  def mod
    @comparision.mods[@index]
  end

  def first?
    index == 0 || mods[index - 1].model_key != mod.model_key
  end
  
  def next?
    index != 0 && mods[index - 1].model_key == mod.model_key
  end
  
  def mid?
    next? && !last?
  end
  
  def last?
    mod == mods.last || mods[index + 1].model_key != mod.model_key
  end
end
