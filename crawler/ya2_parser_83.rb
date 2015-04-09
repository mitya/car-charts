class YA2Parser
  # build metadata
  def step_83
    models_list = CW.read_objects(F13)
    models_by_model_key = models_list.index_by { |model| "#{model.mark}--#{model.model}"}
    models_by_generation_key = models_list.index_by { |model| "#{model.mark}--#{model.model}--#{model.year}"}
    mods = CW.read_data_in_binary(F82)
    stored_metadata = CW.load_dataset("metadata")

    #   # check missing bodytype names
    #   bodytypes = mods.values.map { |h| h['body'] }.uniq
    #   stored_bodytypes = stored_metadata['parameterTranslations']['body'].keys
    #   missing_bodytypes = bodytypes - stored_bodytypes
    #   pp missing_bodytypes unless missing_bodytypes == []
  
    family_keys = mods.map { |key, mod| mod['model_key'] }.uniq.sort
    brand_keys = mods.map { |key, mod| key.split.first }.uniq.sort
    family_keys_set = family_keys.to_set

    generation_keys = mods.values.map { |mod| mod['generation_key'] }.uniq.sort
  
    generation_rows = generation_keys.each_with_object({}) do |generation_key, result|
      model = models_by_generation_key[generation_key]
      puts generation_key unless model
      mark_key, model_key, year = generation_key.split('--')
      family_key = "#{mark_key}--#{model_key}"
      generation_title = "#{model.model_title} #{year}"
      result[generation_key] = [family_key, year, generation_title]
    end

    family_rows = family_keys.each_with_object({}) do |key, result| # { 'bmw--x6' =>  ['X6', 'BMW X6', 'bmw', 'Xe'], ... }
      model = models_by_model_key[key]
      generations = generation_keys.select { |g| g.start_with?(key + '--') }
      result[key] = [ model.model_title, model.title, model.mark, CWD.model_classification[key] || '', generations ]
    end


    models_by_brand = family_keys.each_with_object({}) do |key, result|
      model = models_by_model_key[key]
      (result[model.mark] ||= []) << key
    end


    models_by_class = CWD.model_classification.each_with_object({}) do |(key, klass), result|
      xputs "unused classification key: #{key}" if klass && !family_keys_set.include?(key)
      next unless family_keys_set.include?(key)
      next unless klass
      (result[klass] ||= []) << key
    end


    brand_names = CWD.adjusted_brand_names
    brand_names.delete_if { |key, name| !brand_keys.include?(key) }
  
  
    sample_sets = CW.load_dataset("sample-sets")
        

    metadata = {}
    metadata['generation_rows'] = generation_rows
    metadata['generation_keys'] = generation_keys.sort
    metadata['family_rows'] = family_rows
    metadata['family_keys'] = family_rows.keys.sort
    metadata['category_models'] = models_by_class
    metadata['brand_models'] = models_by_brand
    metadata['brand_names'] = brand_names
    metadata['parameter_keys'] = CWD.used_fields
    metadata['sample_sets'] = sample_sets
    metadata.update stored_metadata

    CW.write_data_to_plist F83, metadata
    # CW.write_data "debug-#{F83}", metadata
  end
end
