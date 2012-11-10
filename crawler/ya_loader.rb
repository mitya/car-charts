# encoding: utf-8

# models.json - vendor,model,year,bodies,other_years
# bodies.json - model_key,key,custom_title,doors,base
# bodies/body-key-*.html
# modifications.json - body_key,trim,engine-transmission-drive
# modifications/body-agregate-*.html
# modifications-final.json - body_key,trim,engine-transmission-drive,*
# delayed_model_ids

class YALoader  
  attr_accessor :workdir, :outdir
  
  def save_home_page
    save_page(YA_ROOT, "ya-home.html")
  end

  def extract_vendor_urls
    vendors = []

    doc = Nokogiri::HTML( open(WORKDIR.join("ya-home.html")) )
    container = doc.css("#content .marks.marks-fav").first

    container.css("li a").each do |link|
      key = link['href'].scan(/mark=([_A-Z]+)/).first.first
      vendors << { title: link.text, url: link['href'], key: key }
    end
  
    open(WORKDIR.join("ya-vendors.json"), "w") { |file| file.write JSON.generate(vendors: vendors) }
  end

  def load_vendor_home_pages
    FileUtils.mkdir_p(WORKDIR + "ya-vendors")
    vendors_info = JSON.parse(File.read(WORKDIR + "ya-vendors.json")).with_indifferent_access
    vendors_info[:vendors].each do |vendor|
      save_page "#{YA_ROOT}/#{vendor[:url]}", "ya-vendors/ya-vendor-#{vendor[:key]}.html"
      sleep 1
    end
  end

  # save_page("http://auto.yandex.ru/models.xml?mark=GREAT_WALL", "ya-great_wall.html")
  def extract_car_urls_from_vendor_page
    models = {}
    Dir.glob(WORKDIR + "ya-vendor-*.html").each do |source|
      vendor_key = source.to_s.scan(/ya-vendor-(\w+)\.html/).first.first

      doc = parse_page(source)
      doc.css("table.marks.all li").to_a.each do |li|
        has_info = li.css("img").any?
        count = li.at_css("i").text.scan(/(\d+)/).first.try(:first).to_i
        if has_info && count > 0
          info_link = li.at_css("a[href^='/catalog']")
          old_cars_link = li.at_css("a[href^='/search']")
          checkbox = li.at_css("input[name=model]")

          model = {key: checkbox[:value], title: old_cars_link.text, url: info_link[:href], vendor_key: vendor_key}
          models["#{vendor_key}_#{model[:key]}"] = model
        end
      end
    end
  
    open(WORKDIR.join("ya-models.json"), "w") { |file| file.write JSON.generate(models: models) }
  end

  def load_model_home_pages
    FileUtils.mkdir_p(WORKDIR + "ya-models")
    metadata = JSON.parse(File.read(WORKDIR + "ya-models.json")).with_indifferent_access
    metadata[:models].each do |key, item|
      unless WORKDIR.join("ya-models/#{key}.html").exist?      
        save_page "#{YA_ROOT}/#{item[:url]}", "ya-models/#{key}.html" 
        sleep 1
      end
    end
  end
  
  def extract_variants
    models_ex = []
    models = JSON.parse(File.read(WORKDIR + "ya-models.json"))['models']
    
    # models.select! { |k,v| k.in?("FORD_FOCUS") }
    
    models.each do |key, model|
      puts "Processing #{key}"
      model[:vendor] = model.delete('vendor_key')
      
      doc = parse_page(WORKDIR + "ya-models/#{key}.html")
            
      doc.css("td.types li:not(.active)").each do |li|
        model[:types_brief] ||= []
        model[:types_brief] << {title: li.text, url: li.at_css("a")[:href]}
      end
      
      model[:review_count] = doc.text_at(".informer-catalog a[href^='/reviews']").to_i
      model[:article_count] = doc.text_at(".informer-catalog a[href^='/articles']").to_i
                        
      type = {}
      type[:string] = doc.text_at("#content h1") # "Ford Focus, универсал, 2011–2012"
      type[:years] = doc.text_at("#content .b-years-tabs .b-years-tabs__selected span") # "2011–2012"
      type[:name] = doc.text_at("td.types li.active")
      doc.search("li.b-years-tabs__notSelected").each do |li|
        type[:older_generations] ||= []
        type[:older_generations] << {years: li.text, url: li.at("a")[:href]}
      end
            
      type[:mods] = []
      doc.css(".complects tbody tr").each do |tr|
        tds = tr.search("td")        
        mod = {pre: {}}        
        mapping = %w(NO NO engine price fuel drive top_speed consumption)
        mapping.prepend("trim") if tr.at("td.name")
        mapping.each_with_index { |k, index| mod[:pre][k.to_sym] = tds[index].try(:text) unless k == 'NO' }
        mod[:url] = tr.at("td.nw a")[:href]
        mod[:pre][:trim] = tr.parent.at("tr:first td:first").text if mod[:pre][:trim].blank?
        type[:mods] << mod
      end

      model[:types] = {}
      model[:types][type[:name]] = type
      
      model.deep_stringify_keys!
      
      models_ex << model
    end
    
    save_data models_ex, "ya-models-ex"
  end
    
  # Read other bodies (w/o the default) from model-ex file and writes them to the ya-bodies.
  def read_other_body_names
    bodies = []
    list = JSON.load(WORKDIR + "ya-models-ex.json")

    list.each do |model|
      (model['types_brief'] || []).each do |body|
        bodies << {vendor: model['vendor'], key: model['key'], body: body['title'], url: body['url']}
      end
    end

    bodies.each(&:deep_stringify_keys!)
    save_data bodies, "ya-bodies"
    
    # # print number of cars per body type
    # bodies = list.map { |mod| mod['types'].keys }.flatten
    # stats = bodies.each_with_object({}) { |b, stats| stats[b] ||= 0; stats[b] += 1}
    # pp Hash[*stats.sort_by {|k,v| v}.flatten]
  end
  
  # Load model pages for all the bodies except the default one
  def load_ya_bodies
    FileUtils.mkdir_p(WORKDIR + "ya-bodies")
    bodies = JSON.load(WORKDIR + "ya-bodies.json")
    
    bodies.each do |ii|
      filename = [KK.escape(ii['vendor']), KK.escape(ii['key']), KK.escape(BODY_TYPES.fetch(ii['body']) { |name| "+" + name.gsub(' ', '_') })].join('-')
      path = WORKDIR + "ya-bodies/#{filename}.html"
      unless path.exist?
        save_page "#{YA_ROOT}/#{ii['url']}", path
        sleep 2
      end
    end    
  end
  
  # Copy the default model html files to the dir with other bodies
  def merge_ya_models_to_ya_bodies
    Dir.glob(WORKDIR + "ya-models/*.html").each do |path|
      doc = parse_page(path)
      vendor, model, body = doc.text_at("p.bc").squish.split(' / ').last(3)

      body_name = BODY_TYPES.fetch(body) { |name| "+" + KK.escape(name) }
      vendor = KK.escape(VENDORS_TRANSLIT.fetch(vendor, vendor))
      filename = [vendor, KK.escape(model), body_name].join('-')
      
      # old_filename = [vendor, model.downcase, BODY_TYPES.fetch(body) { |name| "+" + name }].join('-')
      # old_path = WORKDIR + "ya-bodies/#{old_filename}.html"
      # FileUtils.rm_rf(old_path) if old_filename.split('-').count > 3
      
      new_path = WORKDIR + "ya-bodies/#{filename}.html"
      FileUtils.cp path, new_path unless new_path.exist?
    end
  end
  
  # Add years to file names
  def rename_body_files
    Dir.glob(WORKDIR + "ya-bodies/*.html").first(40000).each do |path|
      vendor, model, body = File.basename(path, '.html').split('-')
      doc = parse_page(path)

      header = doc.text_at(".b-header-adtn h1")
      years = header.split(', ').last # 2008-2012 | 2012
      from, to = years.split('–')
      to = nil if to == "2012"
      years = [from, to].compact.join('-')

      filename = [vendor, model, years, body].join(' ')
      filepath = WORKDIR + "ya-bodies-ex/#{filename}.html"
      FileUtils.cp path, filepath unless filepath.exist?
    end
  end
  
  def rename_bad_models_in_ya_bodies
    Dir.glob(WORKDIR + "ya-bodies-ex/*.html").first(40000).each do |path|
      vendor, model, years, body = File.basename(path, '.html').force_encoding(Encoding::UTF_8).split(' ')
      if model =~ /[а-я]/
        model = KK.escape(Russian.transliterate(model))
        body = Russian.transliterate(body)
        
        model = model.sub("klass", "klasse")
        model = "#{model.scan(/(\d{4})/).first.first}_niva" if model.include?("niva")
        model = "1er_m" if model == "1_seriya_m"
        
        new_filename = [vendor, model, years, body].join(' ')
        FileUtils.mv(path, WORKDIR + "ya-bodies-ex/#{new_filename}.html")
      end
    end
  end

  def rename_bad_bodies_in_ya_bodies
    base_body_types_re = Regexp.new(BASE_BODY_TYPES.keys.join('|'))    
    Dir.glob(WORKDIR + "ya-bodies-ex/*.html").first(40000).each do |path|
      vendor, model, years, body = File.basename(path, '.html').force_encoding(Encoding::UTF_8).split(' ')
      if body =~ Regexp.new("[а-я]")
        body.sub!(base_body_types_re, BASE_BODY_TYPES)
        body.sub!(/(\d)_дв/, '\1d')
        body.sub!(/^\+/, '')
        new_filename = [vendor, model, years, body].join(' ')
        FileUtils.mv(path, WORKDIR + "ya-bodies-ex/#{new_filename}.html")
      end
    end
  end
  
  def save_model_names
    yandex_model_names = []
    Dir.glob(WORKDIR + "ya-models/*.html") do |path|
      filename = File.basename(path, '.html').force_encoding(Encoding::UTF_8)
      yandex_model_names << filename
    end    
    save_data yandex_model_names, "ya-model_names"    
  end
  
  # => vendor_key, model_key, generation, body_key, body_title, model_title, generations, reviews, articles, modifications, trims, agregates
  def parse_bodies_from_body_files
    mods = []
    bodies = Dir.glob(WORKDIR + "ya-bodies/*.html").first(1000).map do |path|
      doc = parse_page(path)
      body = OpenStruct.new
      
      header = doc.text_at("#content h1").gsub(' ', ' ') # "Ford Focus, универсал, 2011–2012"
      breadcrumbs = doc.text_at("p.bc").squish.split(' / ').last(3) # "Ford / Focus / универсал"
      vendor_title, model_title, body_title = breadcrumbs

      body.key = nil
      body.string = header
      body.vendor_key = VendorTitleToKeys[vendor_title]

      body.model_title = model_title.dup
      body.model_title.sub!(/\s?\(USA\)\s?$/, '') # "Toyota 4 Runner (USA)"
      body.model_title.sub!("-класс", '') # "Mercedes-Benz SLR-класс"
      body.model_title = ModelEnglishTitleFixes.fetch("#{vendor_title} #{model_title}", body.model_title)
      body.model_key = KK.escape(body.model_title)
      
      body.body_title = translate_body_name(body_title)
      body.body_key = BODY_TYPES[body_title] || escape_body_key(body.body_title)
      body.bodies = doc.css("td.types li").map { |li| li.text }.join(',')

      body.generation = reformat_years(header.split(', ').last) # 2008-2012 | 2012
      body.generations = doc.search("ul.b-years-tabs li").map { |li| li.text }.join(',')

      body.key = [body.vendor_key, body.model_key, body.generation.underscore, body.body_key].join('--')

      body.review_count = doc.text_at(".informer-catalog a[href^='/reviews']").to_i
      body.article_count = doc.text_at(".informer-catalog a[href^='/articles']").to_i

      doc.css(".complects tbody tr").each do |tr|
        mod = OpenStruct.new
        mod.body_key = body.key
        tds = tr.search("td")
        mapping = %w(NO NO engine price fuel drive top_speed consumption)
        mapping.prepend("trim") if tr.at("td.name")
        mapping.each_with_index { |key, index| mod.send("#{key}=", tds[index].try(:text).to_s.strip.presence) unless key == 'NO' }
        mod.engine = mod.engine.gsub(' ', ' ')
        mod.url = tr.at("td.nw a")[:href]
        mod.trim = tr.parent.at("tr:first td:first").text.presence if mod.trim.blank?
        mods << mod
      end

      body
    end

    save_data bodies.map { |b| b.send(:table) }, "ya-bodies-2"
    save_data mods.map { |b| b.send(:table) }, "ya-mods"
  end
  
  def preprocess_mods
    mods = JSON.load(WORKDIR + "ya-mods.json")
    
    mods.each do |mod|
      volume, gearbox, power = mod['engine'].scan(/^(\d.\d) (\w{2,3}) \((\d+) л.с.\)/).flatten
      drive = Drives.fetch(mod['drive'])
      fuel = ShortFuelSigns.fetch(mod['fuel'])
      mod['agregate'] = [volume + fuel, power + 'ps', gearbox, drive].join('-')
      mod['price'] = mod['price'].gsub(/[^\d]/, '').to_i if mod['price']
      mod['top_speed'] = mod['top_speed'].to_i if mod['top_speed']
      mod.delete_if { |k,v| k.in?('engine', 'fuel', 'drive') }
    end
    save_data mods, "ya-mods-2"    
  end
  
  def filter_uniq_mods
    mods = JSON.load(WORKDIR + "ya-mods-2.json")
    
    uniq_mods = {}
    mods.each do |mod|
      uniq_mods[mod['body_key'] + '---' + mod['agregate']] ||= mod
    end

    save_data uniq_mods.values, "ya-mods-uniq"
  end

  def filter_old_mods
    mods = JSON.load(WORKDIR + "ya-mods-uniq.json").map { |hash| OpenStruct.new(hash) }
    
    mods.reject! do |mod|
      years = mod.body_key.split('--').third
      from, to = years.split('_')
      to ||= '2012'
      to < '2009'
    end
    
    mods.each do |mod|
      mod.key = [mod.body_key, mod.agregate].join('---')
    end

    save_data mods, "ya-mods-fresh"
  end
  
  def parse_related
    results = {}
    Dir.glob(WORKDIR + "ya-bodies/*.html").first(10_000).map do |path|
      doc = parse_page(path)
      
      title = doc.text_at("#content h1").gsub(' ', ' ') # "Ford Focus, универсал, 2011–2012"
      related = doc.search(".related-in-catalog li").map(&:text).join(", ")
      
      results[title] = related
    end
    
    save_data results, "ya-bodies-related"
  end
end
