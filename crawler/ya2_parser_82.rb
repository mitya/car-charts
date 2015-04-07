class YA2Parser
  # parse mod values
  def step_82
    raw_mods = CW.read_hash('08.1-mods', openstruct: false)
    parsed_mods = {}
    excluded_mod_prefixes = %w(zaz gaz)

    raw_mods.first(1_000_000).each do |mod_key, properties|      
      if mod_key.start_with?(*excluded_mod_prefixes)
        next
      end      
      
      parsed = Mash.new

      properties.each do |key, string|
        case key.to_sym
        when :front_suspension, :rear_suspension, :front_brakes, :rear_brakes, :model_title, :body_title, :body_type, :price, :engine_title, :engine_spec, :category
        when :safety_rating_value, :safety_rating_name
        when :fuel_consumption
          values = string.split(%r{ / }).map { |str| CW.to_f(str) }
          parsed[:consumption_city], parsed[:consumption_highway], parsed[:consumption_mixed] = values
        when :bore_and_stroke
          values = string.split(' × ').map { |str| CW.to_f(str) }
          parsed[:bore], parsed[:stroke] = values
        when :max_power # 201 / 148 при 6800  ||  201 / 148 при 6800 – 7000
          values = string.scan(%r{(\d+) / (\d+)(?: при (\d+)(?: – (\d+))?)?}).first
          values.map! { |s| CW.to_i(s) }
          parsed[:max_power], parsed[:max_power_kw], parsed[:max_power_range_start], parsed[:max_power_range_end] = values
        when :max_torque # 600 при 3000 – 4000  ||  600 при 3000
          values = string.scan(%r{(\d+)(?: при (\d+)(?: – (\d+))?)?}).first
          values.map! { |s| CW.to_i(s) }
          parsed[:max_torque], parsed[:max_torque_range_start], parsed[:max_torque_range_end] = values
        when :tires
          parsed[:tires] = string.split(%r{\s}).each_slice(5).map { |items| items.join }.join(' ')
        when :luggage_capacity
          values = string.split(SPACE_RE).map { |str| CW.to_i(str) }
          parsed[:luggage_min], parsed[:luggage_max] = values.first, values.last
        when :seats
          string = '4' if string == '2+2'
          values = string.split(SPACE_RE).map { |str| CW.to_i(str) }
          parsed[:seats_min], parsed[:seats_max] = values.first, values.last
        when :brand_country
          parsed[:brand_country] = TranslationHelper.instance.russian_country_title_to_code(string)
        when :assembly_country
          names = string.split(%r{,\s+})
          names.map! { |rus_name| TranslationHelper.instance.russian_country_title_to_code(rus_name) }
          parsed[:assembly_countries] = names.join(' ')
        when :produced_since, :produced_till
          if string.length > 4
            month, year = string.split(SPACE_RE)
            month_number = Rus_Months.index(month) + 1
            parsed[key] = year.to_i * 100 + month_number
          elsif string.length == 4
            parsed[key] = string.to_i * 100
          end
        when :top_speed, :displacement, :cylinder_count, :cylinder_valves, :gears, :max_power, :max_power_kw, :max_torque,
              :max_power_revs, :max_torque_revs, :length, :width, :height, :ground_clearance, :front_tire_rut, :rear_tire_rut,
              :wheelbase, :luggage_capacity, :tank_capacity, :kerbweight, :gross_mass, :doors, :co2_emission
          parsed[key] = CW.to_i(string)
        when :acceleration_100kmh, :bore, :stroke, :compression, :displacement_key
          parsed[key] = CW.to_f(string)
        when :cylinder_placement, :engine_layout, :fuel, :fuel_rating, :transmission, :drive, :compressor, :injection,
              :front_suspension, :rear_suspension, :front_brakes, :rear_brakes
          parsed[key] = TranslationHelper.instance.translate_value(key, string)
        when :eco_class
          parsed[key] = string
        else
          parsed["__#{key}"] = string
        end
      end

      # replace dashes with spaces in the key
      new_key = ModKey.from_dash_key(mod_key)

      # store key parts as individual elements
      parsed.body = new_key.body
      parsed.model_key = new_key.brand_and_model
      parsed.version_key = new_key.version
      parsed.generation_key = new_key.brand_and_model_and_year
      parsed.year = CW.to_i(new_key.years, zero: false)
      parsed.displacement_key = new_key.displacement || CW.make_displacement_key(parsed.displacement)

      if !new_key.aggregate
        new_key.aggregate = CW.aggregate_key(parsed.displacement_key, parsed.fuel, parsed.max_power, parsed.transmission, parsed.drive)
      end      

      # convert all keys to strings
      # parsed.keys.reject { |k| k.is_a?(String) }.each { |k| parsed[k.to_s] = parsed.delete(k) }

      # remove nil values because plists can't contain it
      parsed.delete_if { |k, v| v.nil? }

      # replace zeros with nils for some keys
      parsed.each { |k, v| parsed.delete(k) if v == 0 && NON_ZERO_KEYS.include?(k) }

      parsed_mods[new_key.to_s_with_spaces] = parsed.hash
    end

    parsed_mods_arrays = {}
    parsed_mods.each do |mod_key, mod_hash|
      parsed_mods_arrays[mod_key] = CWD.used_fields.each_with_index.map { |k, i| mod_hash[k] || '' }
    end

    xvalidate do
      parsed_mods.each_with_object({}) do |(mod_key, hash), result|
        hash.each do |attr_key, val|
          if CW.blank?(val)
            result[attr_key] ||= 0
            result[attr_key] += 1
          end
        end
      end.sort_by { |k, v| v }.each do |key, count| printf "%25s %4i\n", key, count end

      puts

      parsed_mods_arrays.each_with_object({}) do |(mod_key, array), result|
        array.each_with_index do |val, index|
          if CW.blank?(val)
            result[CWD.used_fields[index]] ||= 0
            result[CWD.used_fields[index]] += 1
          end
        end
      end.sort_by { |k, v| v }.each do |key, count| printf "%25s %4i\n", key, count end        
    end
    
    CW.write_data_to_plist "08.2-mods", parsed_mods_arrays  
    CW.write_data_to_binary "08.2-mods", parsed_mods
    CW.write_data "08.2-mods", parsed_mods
    
    CW.write_data_to_plist "debug-08.2-mods", parsed_mods.first(20).to_h
    CW.write_data "debug-08.2-mods.sample", parsed_mods.first(20).map {|k, h| [k, h.sort_by {|a, v| a }.to_h] }.to_h
    CW.write_data "debug-08.2-mods.keys", parsed_mods.keys.sort
  end  

  def step_82_check
    mods = CW.read_data_in_binary('08.2-mods')
    count = 0

    generation_models = {}
    mods.each do |key, mod|
      mod = TalkyHash.new(mod)
      generation_models[mod.generation_key] ||= 0
      generation_models[mod.generation_key] += 1
    end

    generation_models = generation_models.sort_by { |k,c| c }
    generation_models.each do |k,c|
      printf "%-40s %4s\n", k, c
    end    


    # mods.each do |key, mod|
    #   mod = TalkyHash.new(mod)
    #   if !mod.top_speed
    #     printf "%60s %10s\n", key, mod.top_speed
    #     count += 1
    #   end
    # end
    # puts count
  end
end
