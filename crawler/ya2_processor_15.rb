require "enumerator"

class YA2Processor
  F15 = "15-models"
  F15P = "15-models-parsed"
  F15M = "15-mods"
  F16 = "16-models"
  F17 = "17-mods"
  D18 = "18-mods"

  SHIT = Set.new %w(ac ariel bronto bufori byvin caterham changfeng coggiola dadi e_car ecomotors foton fuqi gonow gordon 
    hafei haima haval hawtai hindustan holden huanghai invicta iran_khodro liebao landwind lti mahindra marlin maruti
    morgan noble pagani panoz pgo panoz mitsuoka puch qoros spyker)

  # some models will have no generation
  def step_15
    raw_items = []

    CW.parse_dir(D12) do |doc, basename, path|
      mark_model_bodytype = doc.css_text("title").split(' | ').first

      q = Mash.new
      q.key = basename
      q.title = doc.css_text(".car-head h1")
      q.generation = doc.css_text(".generations button .button__text")
      q.bodytype = mark_model_bodytype.sub q.title + ' ', '' # ".bodytypes button .button__text"
      q.mods = doc.css_count(".b-complectations__item:not(.b-complectations__item_state_current) a.link")

      raw_items << q
    end

    CW.write_objects(F15, raw_items)
  end

  def step_16
    seq15 = CW.read_objects(F15)
    seq11 = CW.read_objects(F11)
    seq11_index = seq11.group_by(&:ya_generation_id)
    seq16 = seq15.map do |q|
      w = Mash.new

      parts = q.key.split
      w.mark = parts[0]
      w.model = parts[1]
      w.yandex_id = parts[2].to_i

      years = q.generation
      years = seq11_index[w.yandex_id].first.years unless years
      w.year, w.year_end = CW.parse_years(years)

      w.bodytype = CW.parse_bodytype(w.mark, q.bodytype, silent:false)
      next unless w.bodytype
      w
    end.compact
    CW.write_objects F16, seq16
  end

  # extract mods
  def step_17
    seq16 = W.read_objects(F16)
    seq16_index = seq16.group_by(&:yandex_id)
    seq17 = {}

    W.parse_dir(D12, silent: true) do |doc, basename, path|
      mark = basename.split(' ').first

      if SHIT.include?(mark)
        # puts "SHIT #{basename}"
        next
      end

      yandex_id = basename.split[2].to_i
      obj = seq16_index[yandex_id]
      
      if !obj
        puts "EXCLUDE #{basename}"
        next
      end
      
      obj = obj.first
      
      doc.css(".b-complectations__item:not(.b-complectations__item_state_current) a.link").each do |a|
        url = a['href']
        engine = W.parse_ya_aggregate_title(a['title'])
        key = [obj.mark, obj.model, obj.year, obj.bodytype, engine].join(' ')
        seq17[key] = url        
      end
    end

    W.write_data(F17, seq17)
  end

  # load mods
  def step_18
    W.read_data(F17).to_a.shuffle.each do |key, url|
      mark, model, year, body, engine = key.split
      old_model_key = [mark, model, year, body].join('-')
      old_key = [ old_model_key, engine ].join('--')
      exist = File.exist?(WORKDIR + "../data_1502/07.0-mods/#{old_key}.html")
      next if exist

      W.save_ya_page_and_sleep url, "#{ D18 }/#{ key }.html", overwrite: false
    end
  end
  

  def step_98
    seq = W.read_data(F17)
    keys = seq.keys
    
    new_keys = keys.map { |key| W.convert_space_key_to_dash_key(key) }
    old_keys = Dir.glob(WORKDIR + "../data_1502/07.0-mods/*.html").map { |path| File.basename(path, '.html') }
    missing_in_new = old_keys - new_keys
    missing_in_old = new_keys - old_keys    
    
    W.write_html missing_in_new
  end
end
