module YAHelper
  module_function

  def parse_page(url)
    Nokogiri::HTML(open(url))
  end

  def save_page(url, path)
    full_path = path.to_s.include?(WORKDIR.to_s) ? path : WORKDIR + path
    open(url, "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:12.0) Gecko/20100101 Firefox/12.0") do |page|
      puts "GET #{url} => #{path}"
      open(full_path, "w") { |file| file.write(page.read) }
    end  
  end
  
  def save_data(data, filename, dir = WORKDIR)
    data = data.map { |b| b.send(:table) } if Array === data && OpenStruct === data.first
    open(dir + "#{filename}.json", "w") { |file| file.write JSON.pretty_generate(data) }
  end

  def save_plist(data, filename, dir = OUTDIR)
    open(dir + "#{filename}.plist", "w") { |file| file.write data.to_plist }
    system "plutil -convert binary1 #{dir}/#{filename}.plist"
  end
  
  def convert_to_plist(source, dir = OUTDIR)
    items = JSON.load(dir + "#{source}.json")
    open(dir + "#{source}.plist", "w") { |file| file.write items.to_plist }
    system "plutil -convert binary1 #{OUTDIR}/#{source}.plist"
  end
    
  def escape(string)
    string = string.strip
    string = string.gsub('+', 'plus')
    string.gsub(/[^\w]/, '_').downcase
  end
  
  def print_hash(hash, options = {})
    key_len = options[:len] || 25
    hash.symbolize_keys!
    hash.each do |k,v|
      printf %{%#{key_len}s %-s,\n}, "#{k}:", v.inspect
    end    
  end

  def reformat_years(years)
    from, to = years.split('–')
    to = nil if to == "2012"
    years = [from, to].compact.join('-')        
  end

  def escape_body_key(en_title)
    escape en_title.sub(/(\d)-dr/, '\1d')
  end
  
  def translate_body_name(rus)
    en = rus.sub(BASE_BODY_TYPES_RE, BASE_BODY_TYPES)    
    en = en.sub("полуторная кабина", "extended cab")    
    en = en.sub("двойная кабина", "double cab")    
    en = en.sub("7 мест", "7 seats")
    en = en.sub("5 мест", "5 seats")
    en = en.sub("cabrio сс", "cabrio cc")
    en = en.sub("sedan 21108 премьер", "sedan 21108")
    en = en.sub("+2", "plus 2")
    en = en.sub(/(\d) дв/, '\1-dr')
  end

  def stats_for_keys(keys)
    stats = keys.each_with_object({}) { |e,h| h[e] = h[e].to_i + 1 }
    Hash[*stats.sort_by {|k,v| v}.flatten]
  end
  
  def to_i(str)
    Integer(str) rescue nil
  end
  
  def to_f(str)
    Float(str) rescue nil
  end
end

KK = YAHelper
YY = KK
