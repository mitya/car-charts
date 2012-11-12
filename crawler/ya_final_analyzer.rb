class YAFinalAnalyzer
  def work
    param = 'body'
    mods = JSON.load(OUTDIR + "db-mods-kv.json")
    # mods = mods.select { |k, mod| mod[param] }
    all = mods.values.map { |mod| mod[param] } 

    # params = %w(version_key model_key)
    # mods.each do |key, mod|
    #   # puts [key, params.map { |p| mod[p] }].compact.join(' | ')
    #   # p [key, mod['displacement_key'], mod['displacement']]
    # end
    # puts "Total: #{mods.count}"

    uniq = all.flatten.uniq.compact.sort
    uniq.each { |val| puts val }
    puts "Total: #{all.count}, non-blank: #{all.compact.count}, uniq: #{uniq.count}" 
  end

  def print_models_by_length
    pp ModelClassification.map { |m, k| m.split('--').join(' ').titleize }.sort_by(&:length)
  end
  
  def print_weird_bodies
    mods = JSON.load(OUTDIR + "db-modifications.json")

    bodies = mods.map { |k,d| k.split(/---?/)[3] }.uniq.sort

    body_mods = {}
    mods.each do |k, data|
      body = k.split(/---?/)[3]
      model = k.split(/---?/).first(2).join(' ')
      body_mods[body] ||= []
      body_mods[body] << model unless body_mods[body].include?(model)
    end
  
    body_mods.reject! { |k,v| v.count > 3 }
    body_mods.sort_by{ |k,v| k}.each do |body, models|
      # printf "%-1i %-33s #{models.join(', ')}\n", models.count, body
      printf %{%-35s  %-35s # #{models.join(', ')}\n}, %{#{body}:}, %{:#{body},}
      # puts %{"#{body}" => "#{body}", # #{models.join(', ')}}
    end
  end

  def print_bodies
    mods = JSON.load(OUTDIR + "db-modifications.json")

    models = Set.new
    mods.keys.each do |key|
      model_key = key.split('--').first(4).join('--')
      models << model_key
    end
    
    models.each do |model|
      brand, model, years, body = model.split('--')
      brand_body = [brand, body].join('--')
      brand_model_body = "#{brand}--#{model}--#{body}"
      next if Reductions_Body_Body.include?(brand_body)
      next if Reductions_Body_Model.include?(brand_body)
      next if Reductions_Body_Version.include?(brand_model_body)
      # printf %{%-40s %s\n}, [brand, model].join('--'), body
      printf %{%-45s  %-35s\n}, %{"#{brand_model_body}"}, %{=> "#{body}",}      
    end
  end      
end