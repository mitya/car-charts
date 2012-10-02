class ModificationSet
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  class << self
    def all
      %w(SUVs Hatchbacks Mid-Class).map { |name| ModificationSet.new(name) }
    end
  end
end
