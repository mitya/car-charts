class Comparision
  attr_accessor :mods, :params
  
  def initialize(mods, params)
    @mods = mods
    @activeMods = nil
    @uniqMods = nil
    @params = params
    @values ||= {}
    @min_values ||= {}
    @max_values ||= {}
    @ranges ||= {}
    @containsOnlyBodyParams = nil
    @all_values = {}
  end


  def allValuesFor(param)
    @all_values[param] ||= mods.map do |mod|
      mod.parameterValue(param.key).valueInUnit(param.defaultUnitKeyInCurrentSystem)
    end
  end
  
  def valuesFor(param)
    @values[param] ||= mods.map do |mod|
      mod.parameterValue(param.key).valueInUnit(param.defaultUnitKeyInCurrentSystem)
    end.compact.uniq do |value|
      value.to_f # a weird hack, uniq by itself doesn't work sometimes
    end
  end
  
  def maxValueFor(param)
    @max_values[param] ||= valuesFor(param).max || 0
  end

  def minValueFor(param)
    @min_values[param] ||= valuesFor(param).min || 0
  end
  
  def rangeFor(param)
    @ranges[param] ||= maxValueFor(param) - minValueFor(param)
  end
  
  def relativeValueFor(param, value)
    range = rangeFor(param).to_f
    value ||= 0
    return 1.0 if range == 0
    return (value - minValueFor(param)) / range
  end

  
  def items
    @items ||= (0...mods.count).map { |index| Item.new(self, index) }
  end

  def mods
    @activeMods ||= containsOnlyBodyParams? ? uniqMods : @mods
  end
  
  def allMods
    @mods
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
    @containsOnlyBodyParams = params.all? { |param| param.appliesToBody? } if @containsOnlyBodyParams.nil?
    @containsOnlyBodyParams
  end
  
  def incomplete?
    mods.empty? || params.empty?
  end
  
  def complete?
    !incomplete?
  end


  class Item
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
      index == 0
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
    
    def to_s
      "CI(#{index}, #{mod.key})"
    end
    
    def inspect
      to_s
    end
  end
end
