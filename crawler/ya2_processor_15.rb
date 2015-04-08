class YA2Processor
  F15 = "15-models"
  F15P = "15-models-parsed"
  F15M = "15-mods"
  F16 = "16-models"
  F17 = "17-mods"

  SHIT = Set.new %w(ac ariel bronto bufori byvin caterham changfeng coggiola dadi e_car ecomotors foton fuqi gonow gordon hafei haima haval hawtai
    hindustan holden huanghai invicta iran_khodro liebao landwind lti mahindra marlin maruti morgan noble pagani panoz pgo panoz
    mitsuoka puch qoros spyker)
  
  # some models will have no generation
  def step_15
    # seq11 = CW.read_objects(FIL_11)
    # seq11_index = seq11.group_by(&:ya_generation_id)
    
    raw_items = []    
    # parsed_items = []
    # links_by_model = {}
    
    CW.parse_dir(D12) do |doc, basename, path|
      mark_model_bodytype = doc.css_text("title").split(' | ').first

      q = Mash.new
      q.key = basename
      q.title = doc.css_text(".car-head h1")
      q.generation = doc.css_text(".generations button .button__text")
      q.bodytype = mark_model_bodytype.sub q.title + ' ', '' # ".bodytypes button .button__text"
      q.mods = doc.css_count(".b-complectations__item:not(.b-complectations__item_state_current) a.link")
        
      # links = []
      # doc.css(".b-complectations__item:not(.b-complectations__item_state_current) a.link").each do |a|
      #   
      #   links << a['href']
      # end
      #
      # w = Mash.new
      # parts = basename.split
      # w.mark = parts[0]
      # w.model = parts[1]
      # w.yandex_id = parts[2].to_i
      # w.bodytype = CW.parse_bodytype(w.mark, q.bodytype, silent: true)
      #
      # years = q.generation
      # years = seq11_index[w.yandex_id].first.years unless years
      # w.year, w.year_end = CW.parse_years(years)
      #
      # model_key = [w.mark, w.model, w.year, w.bodytype].join(' ')
      # links_by_model[model_key] = links
      #
      # parsed_items << w if w.bodytype
      raw_items << q
    end
    
    CW.write_objects(F15, raw_items)
    # CW.write_objects(F15P, parsed_items)
    # CW.write_data(F15M, links_by_model)
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

      w.bodytype = CW.parse_bodytype(w.mark, q.bodytype, silent: true)
      next unless w.bodytype
      w
    end.compact
    CW.write_objects F16, seq16
  end

  def step_16v
    seq = CW.read_objects(F16)
    
    g = seq.group_by(&:yandex_id)
    g = g.map(&:last).select { |q| q.size > 1 }
    p g.first
    
    # seq.reject! { |q| SHIT.include?(q.mark) }
    # seq.select! { |q| q.bodytype == nil }
    # seq.each do |q|
    #   printf "%-40s %-40s %-40s %-40s %-4s\n", q.key, q.title, q.bodytype, q.generation, q.mods
    # end
    puts seq.count
  end
  
  # extract mods
  def step_17
    seq16 = CW.read_objects(F16)
    seq16_index = seq16.group_by(&:yandex_id)
    seq17 = {}

    CW.parse_dir(D12, silent: true) do |doc, basename, path|
      mark = basename.split(' ').first
      next if SHIT.include?(mark)
      doc.css(".b-complectations__item:not(.b-complectations__item_state_current) a.link").each do |a|
        parts = basename.split
        yandex_id = parts[2].to_i        
        url = a['href']        
        engine = CW.parse_ya_aggregate_title(a['title'])
        
        obj = seq16_index[yandex_id]
        if obj
          obj = obj.first
          key = [obj.mark, obj.model, obj.year, obj.bodytype, engine].join(' ')
          seq17[key] = url
        else
           # the model was filtered out before
           puts "exclude #{url}"
        end
      end
    end
    
    CW.write_data(F17, seq17)
  end
  
  
  # # load mods
  # def step_19
  #   rs = []
  #   CW.read_data(F15R).each do |url|
  #     components = url.split('/')
  #     mark = components[1]
  #     model = components[2]
  #     generation_id = components[3]
  #     generation_complectation_engine_id = components[5]
  #     engine_id = generation_complectation_engine_id.split('_').last
  #     name = [mark, model, generation_id, engine_id].join(' ')
  #     rs << name
  #     puts name
  #     # CW.save_ya_page_and_sleep path, "#{DIR_14}/#{ path.split('/').join(' ').strip }.html", overwrite: false
  #   end
  #   p rs.count
  #   p rs.uniq.count
  # end
end
