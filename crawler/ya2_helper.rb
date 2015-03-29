module CW
  module_function

  def save_page(url, path, overwrite: true, dir: WORKDIR, test: false)
    if test
      puts "WILL WRITE #{path}" unless File.exist?(dir + path)
      return false
    end
    
    if !overwrite && File.exist?(dir + path)
      puts "EXIST #{path}" 
      return false
    end
    
    open(url, "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:35.0) Gecko/20100101 Firefox/35.0") do |page|
      puts "GET #{url} => #{path}"
      write_file(dir + path, page.read)
    end
    
    return true
  end
  
  def save_page_and_sleep(url, path, overwrite: true, sleep_interval: 1..3, test: false)
    saved = save_page url, path, overwrite: overwrite, test: test
    sleep rand(sleep_interval) if saved
  end
  
  def save_ya_page_and_sleep(ya_path, path, overwrite: true, test: false)
    save_page_and_sleep YA_HOST + ya_path, path, overwrite: overwrite, test: test
  end
  
  def write_file(path, content)
    open(path, "w") { |file| file.write(content) }
  end

  def parse_file(file, silent:false)
    puts "Parsing #{file}" unless silent
    return Nokogiri::HTML(open(file))
  end

  def write_data(filename, data, dir: WORKDIR)
    path = "#{dir}/#{filename}.yaml"

    if data.is_a?(Array)
      data.map! &:to_h if data.first.is_a?(OpenStruct)      
    end
    
    puts "Write #{data.size if data.respond_to?(:size)} items to #{path}"

    open(path, "w") { |f| f.write YAML.dump(data) }
  end

  def write_data_to_json(filename, data, dir = WORKDIR)
    open("#{dir}/#{filename}.json", "w") { |f| f.write JSON.pretty_generate(data) }
  end
  
  def write_data_to_plist(filename, data, dir: WORKDIR)
    open(dir + "#{filename}.plist", "w") { |file| file.write data.to_plist }
    system "plutil -convert binary1 #{dir}/#{filename}.plist"
  end
  
  
  def write_csv(data)
    path = "#{WORKDIR}/output.csv"    
    
    if data.is_a?(Array)
      data.map! &:to_h if data.first.is_a?(OpenStruct)
      puts "Write #{data.size} items to #{path}"
    end

    open(path, "w") { |f| f.write data.map { |row| CSV.generate_line(row) }.join }
  end

  def read_hash(filename, dir = WORKDIR, openstruct:true)
    data = YAML.load( File.read("#{dir}/#{filename}.yaml") )
    if openstruct
      case data
      when Array 
        data.map { |hash| OpenStruct.new(hash) }
      when Hash        
        data.each { |k, h| data[k] = OpenStruct.new(h) }
        data
      end
    else
      data
    end
  end
  
  def read_hash_in_json(filename, dir = WORKDIR)
    return JSON.parse File.read("#{dir}/#{filename}.json")
  end
  
  def parse_dir(directory, limit: nil, silent: false, only: nil)
    count = 0
    sec = Benchmark.realtime do
      pattern = if only
        '{' + only.join(',') + '}'
      else
        '*'
      end
      Array(directory).each do |dir|
        Dir.glob("#{WORKDIR + dir}/#{pattern}.html").each do |path|
          count += 1
          return if limit && count == limit
          basename = File.basename(path, '.html')
          doc = CW.parse_file(path, silent:silent)
          yield doc, basename, path
        end
      end
    end

    printf "Processed #{count} files in %02d:%02d sec\n", *sec.divmod(60)
  end
  
  def compress_dir(dir, outdir, selectors, limit: nil, zip: true)
    outdir = dir unless outdir
    FileUtils.mkdir_p File.join(WORKDIR, outdir)
    if zip
      puts "compressing #{WORKDIR + dir}"
      system "tar cjf #{WORKDIR + dir}.tbz -C #{WORKDIR + dir} ."
    end
    parse_dir(dir, limit: limit) do |doc, basename, path|
      content = doc.css(selectors)
      content.xpath('//@data-bem').remove
      content.xpath('//@style').remove
      content.xpath('//img').remove
      
      doc.at_css('body').inner_html = content
      doc.at_css('head').inner_html = ''
    
      new_path = File.join(WORKDIR, outdir, "#{basename}.html")
    
      write_file(new_path, doc.to_html)
    end    
  end
  
  def to_i(str)
    # Integer(str) rescue nil
    str.to_i
  end

  def to_f(str)
    # Float(str) rescue nil
    str.to_f
  end
  
  def stringify_keys(hash)
    hash = hash.to_h if hash.is_a?(OpenStruct)
    hash.keys.each { |k| hash[k.to_s] = hash.delete(k) if k.is_a?(Symbol) }
    hash
  end
  
  # def convert_to_plist(source, dir = OUTDIR)
  #   items = JSON.load(dir + "#{source}.json")
  #   open(dir + "#{source}.plist", "w") { |file| file.write items.to_plist }
  #   system "plutil -convert binary1 #{OUTDIR}/#{source}.plist"
  # end

  def escape(string)
    string = string.strip
    string = string.gsub('+', 'plus')
    string.gsub(/[^\w]/, '_').downcase
  end

  # def print_hash(hash, options = {})
  #   key_len = options[:len] || 25
  #   hash.symbolize_keys!
  #   hash.each do |k,v|
  #     printf %{%#{key_len}s %-s,\n}, "#{k}:", v.inspect
  #   end
  # end
  #
  # def reformat_years(years)
  #   from, to = years.split('–')
  #   to = nil if to == "2012"
  #   years = [from, to].compact.join('-')
  # end
  #
  # def escape_body_key(en_title)
  #   escape en_title.sub(/(\d)-dr/, '\1d')
  # end
  #
  # def translate_body_name(rus)
  #   en = rus.sub(BASE_BODY_TYPES_RE, BASE_BODY_TYPES)
  #   en = en.sub("полуторная кабина", "extended cab")
  #   en = en.sub("двойная кабина", "double cab")
  #   en = en.sub("7 мест", "7 seats")
  #   en = en.sub("5 мест", "5 seats")
  #   en = en.sub("cabrio сс", "cabrio cc")
  #   en = en.sub("sedan 21108 премьер", "sedan 21108")
  #   en = en.sub("+2", "plus 2")
  #   en = en.sub(/(\d) дв/, '\1-dr')
  # end
  #
  # def stats_for_keys(keys)
  #   stats = keys.each_with_object({}) { |e,h| h[e] = h[e].to_i + 1 }
  #   Hash[*stats.sort_by {|k,v| v}.flatten]
  # end
  #

  # Momentum 1.6 AMT (150 л.с.) передний привод, бензин
  # sDrive30i 3.0 AT (258 л.с.) задний привод, бензин
  # 1.4 MT (125 л.с.) передний привод, бензин
  # 4.4 AT (540 л.с.)
  def parse_ya_aggregate_title(title)
    title = title.strip
    re = /(\d\.\d) (\w{2,3}) \((\d+) л\.с\.\) (\p{L}+) привод, ([\p{L}\s\/]+)$/
    volume, transmission, power, drive, fuel = title.scan(re).flatten
    transmission_key = transmission
    drive_key = CWD::Translations_Values[:drive][drive]
    fuel_key = CWD::Translations_Values[:fuel_short][fuel]
    "#{volume}#{fuel_key}-#{power}ps-#{transmission_key}-#{drive_key}"
  end
  
  # :opel, хэтчбэк 5 дв => hatch5d
  # :mercedes, седан AMG Long => sedan_long
  # :mercedes, черти-что => nil
  def parse_bodytype(mark_key, bodytype_name)
    @reductions ||= YAML.load_file("crawler/data-reductions.yml")
    reduction = @reductions['body_body_new'][ "#{mark_key} #{bodytype_name}" ]
    printf "%-20s %30s  %-30s  %20s\n", 'reduce', mark_key, bodytype_name, reduction if reduction
    bodytype_name = reduction if reduction

    body_key = CWD::Bodies[bodytype_name]
    printf "%-20s %30s  %s\n", 'no match', mark_key, bodytype_name unless body_key    
    body_key
  end
end
