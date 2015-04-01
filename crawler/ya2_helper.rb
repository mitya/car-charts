module CW
  module_function

  def to_i(str, zero: false)
    return nil if (str == '' || str == nil) & zero
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
  
  def escape(string)
    string = string.strip
    string = string.gsub('+', 'plus')
    string.gsub(/[^\w]/, '_').downcase
  end

  def blank?(val)
    val == nil || val == '' || val == 0
  end

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

  # Momentum 1.6 AMT (150 л.с.) передний привод, бензин => 1.6i-150ps-AMT-FWD
  # sDrive30i 3.0 AT (258 л.с.) задний привод, бензин
  # 1.4 MT (125 л.с.) передний привод, бензин
  # 4.4 AT (540 л.с.)
  def parse_ya_aggregate_title(title)
    title = title.strip
    re = /(\d\.\d) (\w{2,3}) \((\d+) л\.с\.\) (\p{L}+) привод, ([\p{L}\s\/]+)$/
    volume, transmission, power, drive, fuel = title.scan(re).flatten
    transmission_key = transmission
    drive_key = CWD.translations(:drive, drive)
    fuel_key = CWD.translations(:fuel, fuel)
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

    body_key = CWD.bodytypes_by_title[bodytype_name]
    printf "%-20s %30s  %s\n", 'no match', mark_key, bodytype_name unless body_key    
    body_key
  end
  
  # 2993 => '3.0'
  def make_displacement_key(displacement)
    "%.1f" % (displacement.to_f / 1000)
  end
  
  # {mod hash} => alfa_romeo giulietta 2010 hatch_5d 2.0d-150ps-MT-FWD
  def build_key_from_mod(m)
    m = OpenStruct.new(m)
    mark, model = m['generation_key'].split('--')
    aggregate = aggregate_key(m.displacement_key, m.fuel, m.max_power, m.transmission, m.drive)
    
    [mark, model, m.year, m.body, aggregate].join(' ')
  end

  def aggregate_key(displacement, fuel, power, transmission, drive)
    displacement_and_fuel = [displacement, fuel].compact.join
    aggregate = [displacement_and_fuel, "#{power}ps", transmission, drive].join('-')
  end
  
  def bm(label = "Action", &block)
    s = Time.now
    result = yield
    puts "#{label} took: #{Time.now - s}s"
    result
  end
  
  def profile_start
    @time = Time.now
  end
  
  def profile
    puts "time: #{Time.now - @time}s"
    @time = Time.now
  end
end
