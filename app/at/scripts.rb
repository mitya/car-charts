module Scripts
  module_function
  
  def modNames
    Model.all.map { |m| m.mods.first.modName(Mod::NameBodyEngineVersion | Mod::NameModel) }.sort_by(&:length).reverse
  end

  def run
    modNames.each { |s| puts s }
  end
end