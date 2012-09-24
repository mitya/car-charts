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

  def mods
    @activeMods ||= onlyBodyParams? ? uniqMods : @mods
  end

  def uniqMods
    @uniqMods ||= @mods.uniqBy { |m| "#{m.model.key}-#{m.body}" }
  end
  
  def title
    return "Select some cars..." if params.count == 0
    return params.first.name if params.count == 1
    "#{params.first.name} +#{params.count - 1}"
  end
  
  def onlyBodyParams?
    return @onlyBodyParams unless @onlyBodyParams == nil
    @onlyBodyParams = params.all? { |param| Parameter::BodyParameters.containsObject(param.key) }
  end
  
  def incomplete?
    mods.empty? || params.empty?
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
    index == 0 || mods[index - 1].model != mod.model
  end
  
  def next?
    index != 0 && mods[index - 1].model == mod.model
  end
  
  def mid?
    next? && !last?
  end
  
  def last?
    mod == mods.last || mods[index + 1].model != mod.model
  end
end
