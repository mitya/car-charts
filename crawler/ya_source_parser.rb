class YASourceParser
  BrokenModPages = %w(
    bmw--x1--2009--crossover---3.0i-218ps-AT-4WD
    jaguar--xk--2009--cabrio---5.0i-385ps-AT-RWD
    jaguar--xk--2009--cabrio_r---5.0i-510ps-AT-RWD
    jaguar--xk--2009--coupe---5.0i-385ps-AT-RWD
    jaguar--xk--2009--coupe_r---5.0i-510ps-AT-RWD
    seat--leon--2009--hatch_5d---2.0i-211ps-AMT-FWD
    seat--leon--2009--hatch_5d---2.0i-240ps-MT-FWD
  )

  def download_mod_page(key, url, force = false)
    path = WORKDIR + "ya-mods/#{key}.html"
    if !path.exist? || force
      save_page "#{YA_ROOT}/#{url}", path
      sleep 5 - rand(4)
    end
  end

  def load_mod_pages
    FileUtils.mkdir_p(WORKDIR + "ya-mods")
    mods = JSON.load(WORKDIR + "ya-mods-front-3-fresh.json").map { |hash| OpenStruct.new(hash) }

    mods.each do |mod|
      next if MODS.present? && !mod.key.in?(MODS)
      download_mod_page(mod.key, mod.url, mod.key.in?(MODS))
    end
  end

  def find_broken_mod_pages
    Dir.glob(WORKDIR + "ya-mods/*.html").each do |path|    
      filename = File.basename(path, ".html")
      text = File.read(path)
      puts filename if text.include?("Вы не выбрали автомобили для сравнения")
    end
  end
  
  def delete_broken_mod_pages
    BrokenModPages.each do |filename|
      File.delete(WORKDIR + "ya-mods/#{filename}.html")
    end
  end

  def parse_mod_pages_to_russian_hashes
    mods = {}
    Dir.glob(WORKDIR + "ya-mods/*.html").first(100000).each do |path|
      filename = File.basename(path, ".html")
      doc = parse_page(path)
      mod = {}
      
      doc.search("table.complects.all .techn:not(.comfort) td.n", "table.complects.all .one-header td.n").each do |td|
        mod[td.text] = td.next_element.text
      end

      mod["model_title"], mod["body_title"] = doc.text_at("h1").split(',')
      mod["engine_title"] = doc.text_at("table.complects.all .one-header h6:first-child")
      mod["engine_spec"] = doc.text_at("table.complects.all .one-header i")
      mod["price"] = doc.text_at("table.complects.all .one-header h6.price")

      mod.each { |k,v| v.gsub!(/ +/, ' ') }
      %w(model_title body_title engine_title engine_spec price).each { |k| mod[k].strip! }

      mods[filename] = mod
    end
        
    save_data mods, "ya-mods-rus"
  end
  
  def parse_complectations_from_mod_pages_to_rus_hashes
    complects = []
    Dir.glob(WORKDIR + "ya-mods/*.html").first(100).map do |path|
      filename = File.basename(path, ".html")
      doc = parse_page(path)
      complect = {'key' => filename}

      doc.search("table.complects.all .techn.comfort td.n").each do |td|
        complect[td.text] = td.next_element.text
      end

      complects << complect if complect.count > 1
    end
  
    save_data complects, "ya-complects"
  end  
end
