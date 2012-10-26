class Comparision
  attr_accessor :mods, :params
  
  def initialize(mods, params)
    @mods = mods
    @params = params
  end
  
  def valuesFor(param)
    @values ||= {}
    @values[param] ||= mods.map { |mod| mod[param] }.compact
  end
  
  def maxValueFor(param)
    @max_values ||= {}
    @max_values[param] ||= valuesFor(param).max
  end

  def minValueFor(param)
    # @min_values ||= {}
    # @min_values[param] ||= valuesFor(param).min
    0
  end
  
  def rangeFor(param)
    @ranges ||= {}
    @ranges[param] ||= maxValueFor(param) - minValueFor(param)
  end
  
  def items
    @items ||= (0...mods.count).map { |index| ComparisionItem.new(self, index) }
  end

  def mods
    @activeMods ||= containsOnlyBodyParams? ? uniqMods : @mods
  end

  def uniqMods
    @uniqMods ||= @mods.uniqBy { |m| "#{m.model.key}-#{m.body}" }
  end
  
  def title
    return "Select some cars..." if params.count == 0
    return params.first.name if params.count == 1
    "#{params.first.name} +#{params.count - 1}"
  end
  
  def containsOnlyBodyParams?
    @containsOnlyBodyParams ||= params.all? { |param| param.appliesToBody? } unless defined?(@containsOnlyBodyParams)
  end
  
  def incomplete?
    mods.empty? || params.empty?
  end
  
  def complete?
    !incomplete?
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

  def firstForModel?
    index == 0 || mods[index - 1].model != mod.model
  end
  
  def nextForModel?
    !firstForModel?
  end
  
  def midForModel?
    !firstForModel? && !lastForModel?
  end
  
  def lastForModel?
    mod == mods.last || mods[index + 1].model != mod.model
  end
end
