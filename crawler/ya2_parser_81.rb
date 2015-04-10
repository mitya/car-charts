class YA2Parser
  def step_81 # parse mods to raw
    mods = W.read_data(F17)
    models = W.read_objects(F13)
    firsts = models #.select { |model| model.count == 1 }

    files = mods.map do |key, url|
      new_file = WORKDIR + "#{D18}/#{key}.html"
      next [key, new_file] if File.exist?(new_file)      
      old_key = W.convert_space_key_to_dash_key(key)
      old_file = WORKDIR + "../data_1502/07.0-mods/#{old_key}.html"
      [key, old_file]
    end

    files += firsts.map { |model| [model.key, "#{WORKDIR}#{model.path}"] }

    p files.select { |key, file| file.to_s.include? '/18-mods/' }.count
    p files.select { |key, file| file.to_s.include? '/07.0-mods/' }.count
    p files.select { |key, file| file.to_s.include? '/12-mods-pass1n2/' }.count

    results = {}
    files.each do |key, path|
      result = results[key] = {}
      doc = W.parse_file(path)
      doc.css(".b-specifications__details .b-features__item_type_specs").each do |div|
        name = div.at_css(".b-features__name").text
        name_translation = TranslationHelper.instance.translate_parameter(name)
        value = div.at_css(".b-features__value").text.strip

        puts "TRANSLATION MISSING: #{name}" unless name_translation
        result[name_translation.to_s] = value
      end
    end

    W.write_data F81, results
  end
end
