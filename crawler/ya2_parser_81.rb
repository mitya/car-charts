class YA2Parser
  def step_81 # parse mods to raw
    results = {}

    parser = lambda do |doc, basename, path|
      result = results[basename] = {}

      doc.css(".b-specifications__details .b-features__item_type_specs").each do |div|
        name = div.at_css(".b-features__name").text
        name_translation = TranslationHelper.instance.translate_parameter(name)
        value = div.at_css(".b-features__value").text.strip

        puts "TRANSLATION MISSING: #{name}" unless name_translation
        result[name_translation.to_s] = value
      end
    end

    CW.parse_dir("07.0-mods", &parser)

    unique_mod_keys = CW.read_hash "06.1-mods-singles", openstruct: false
    unique_mod_keys.each do |basename|
      path1 = WORKDIR + "04.4-bodies-renamed" + "#{basename}.html"
      path2 = WORKDIR + "04.6-bodies-other" + "#{basename}.html"
      path = File.exist?(path1) ? path1 : path2
      doc = CW.parse_file(path, silent: true)
      parser.call(doc, basename.split(' ').join('-'), path)
    end

    CW.write_data "08.1-mods", results
  end
end
