class YA2Processor
  # extract mods
  def step_17
    models = read_objects(F13)
    models_index = models.index_by(&:yandex_id)
    seq17 = {}

    parse_dir(D12, silent: true) do |doc, basename, path|
      mark = basename.split(' ').first

      yandex_id = basename.split[2].to_i
      ref = models_index[yandex_id]      
      puts "EXCLUDE #{basename}" unless ref
      next unless ref

      doc.css(".b-complectations__item:not(.b-complectations__item_state_current) a.link").each do |a|
        url = a['href']
        engine = parse_ya_aggregate_title(a['title'])
        key = [ref.mark, ref.model, ref.year, ref.bodytype, engine].join(' ')
        seq17[key] = url        
      end      
    end

    write_data(F17, seq17)
  end

  # load mods
  def step_18
    W.read_data(F17).to_a.shuffle.each do |key, url|
      dash_key = W.convert_space_key_to_dash_key(key)
      next if File.exist?(WORKDIR + "../data_1502/07.0-mods/#{dash_key}.html")
      W.save_ya_page_and_sleep url, "#{ D18 }/#{ key }.html", overwrite: false
    end
  end
  
  # find mod files with filename model not matching content model (seems there are none)
  def step_18bad
    seq16 = W.read_objects(F13)
    seq16_index = seq16.group_by(&:yandex_id)

    CW.parse_dir(D18, silent: true) do |doc, basename, path|
      link = doc.at_css('.heading a.link')
      parts = link['href'].split('/')
      content_id = parts[3]   
      
      ref = seq16_index[content_id.to_i].first
      ref_key = [ref.mark, ref.model, ref.year, ref.body].join(' ')
      file_key = basename.split.first(4).join(' ')
      
      p [ref_key, file_key] unless ref_key != file_key
    end
  end
  
  def step_00_compare_old_and_new_singles
    old_singles = W.read_data('06.1-mods-singles')
    models = W.read_objects(F13)
    models.select! { |model| model.count == 1 }
    new_singles = models.map { |m| [m.mark, m.model, m.year, m.bodytype].join(' ') }
    pp old_singles - new_singles    
  end

  def step_00_compare_old_and_new_mods
    mods = W.read_data(F17)
    keys = mods.keys
    new_keys = keys.map { |key| W.convert_space_key_to_dash_key(key) }
    old_keys = Dir.glob(WORKDIR + "../data_1502/07.0-mods/*.html").map { |path| File.basename(path, '.html') }
    missing_in_new = old_keys - new_keys
    missing_in_old = new_keys - old_keys
    write_html missing_in_new
  end
end
