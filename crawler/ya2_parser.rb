# Parses mods pages
#
# Оценка безопасности не распарсена так как она не представлена в текстовом виде
#
#
# dir(07-mods-stripped) => step_8_1__html_to_hashes_with_en_keys => file(08.1-mods.yaml)
# file(08.1-mods.yaml) => step_8_2__parse_mod_values => file(08.2-mods.yaml) & file(08.2-mods.plist)
#
class YA2Parser
  SPACE_RE = %r{\s+}
  NON_ZERO_KEYS = [:consumption_city, :consumption_highway, :consumption_mixed, :gears, :ground_clearance, :bore, :luggage_min, :luggage_max].to_set

  def step_8
    run_step 81
    run_step 82
    run_step 83
  end

  def step_8_check_model_keys
    models = CW.read_hash('03-models', openstruct: true)
    mods = CW.read_hash('08.2-mods', openstruct: false)

    model_keys = mods.map { |key, mod| mod['model_key'] }.uniq.sort
    unused_model_keys = models.keys - model_keys
    model_keys.each { |k| puts k }
  end

  def step_8_check_mods
    mods = CW.read_hash('08.2-mods', openstruct: false)
    # models = CW.read_hash('03-models', openstruct: true)
    # metadata = CW.read_hash('debug-08.3-metadata', openstruct: false)

    # mods.each do |keys, mod|
    #   printf "%40s %-s\n", mod['generation_key'], mod['model_key']
    # end
    
    # models.delete_if { |key, model| !metadata['model_keys'].include? key }
    # models.sort.each do |key, model|
    #   printf "%40s %-s\n", model.key, model.full_title
    # end

    # prints mods which key doesn't match the content of the file
    mods.each do |key, mod|
      alt_key = CW.build_key_from_mod(mod)
      if key != alt_key && !alt_key.start_with?(key)
        puts "mismatch key: #{key}, data: #{alt_key}"
      end
    end
  end
  
  def run_step(step_name)
    puts "--- Step #{step_name}"
    send("step_#{step_name}")
  end

  class TranslationHelper
    def self.instance
      @instance ||= new
    end

    def initialize
      @data = YAML.load_file("crawler/data-translations.yml")
      @parameters = @data['parameters'].invert

      @values = @data['values']
      @values.each do |k, hash|
        @values[k] = hash.invert
      end

      @countries = YAML.load_file("crawler/data-countries.yml")['country_code_to_russian'].invert
    end

    def translate_parameter(russian_name)
      @parameters[russian_name.strip]
    end

    def translate_value(category, russian_name)
      @values[category][russian_name.strip]
    end

    def russian_country_title_to_code(russian_name)
      @countries[russian_name]
    end
  end
end
