class YA2Parser
  class ModKey
    attr_accessor :brand, :model, :years, :body, :aggregate
    attr_accessor :version
    attr_accessor :engine, :power, :transmission, :drive

    def initialize(attrs = {})
      attrs.each { |k,v| send("#{k}=", v) }
    end

    def to_s_with_spaces
      [brand, model, years, body, aggregate].join(' ').strip
    end

    def displacement
      engine[0..-2] if engine
    end

    def brand_and_model
      [brand, model].join('--')
    end

    def model_and_version
      [model, version].join('.')
    end
  
    def brand_and_model_and_year
      [brand, model, years].join('--').strip
    end

    def inspect
      to_s_with_spaces
    end
    
    #  in: alfa_romeo-giulietta-2010-hatch_5d--1.4i-170ps-MT-FWD
    # out: alfa_romeo giulietta 2010 hatch_5d 1.4i-170ps-MT-FWD
    def self.from_dash_key(old_key)
      model_years_body, aggregate = old_key.split('--')
      brand, model, years, body = model_years_body.split('-')
      engine, power, transmission, drive = aggregate.split('-') if aggregate

      # years.gsub!('_', '-')
      # puts years if years.include?('_')
      #
      # branded_body = "#{brand}--#{body}"
      # branded_model_body = "#{brand}--#{model}--#{body}"
      #
      # body = Reductions_Body_Body[branded_body]
      # puts body if Reductions_Body_Body[branded_body]
      #
      # if body_key_and_model_name = Reductions_Body_Model[branded_body]
      #   puts body_key_and_model_name
      #   body, model_name = body_key_and_model_name.split(' ', 2)
      #   model = CW.escape(model_name)
      # end
      #
      # if body_key_and_version_name = Reductions_Body_Version[branded_model_body]
      #   puts body_key_and_version_name
      #   body, version = body_key_and_version_name.split(' ', 2)
      #   model = "#{model}.#{CW.escape(version)}"
      # end

      new(brand: brand, model: model, years: years, body: body, aggregate: aggregate, engine:engine, power:power, transmission:transmission, drive:drive)
    end
    
    def self.from_space_key(space_key)
      brand, model, years, body, aggregate = space_key.split
      body_base, body_version = body.split('.')
      engine, power, transmission, drive = aggregate.split('-') if aggregate
      new(brand: brand, model: model, years: years, body: body, aggregate: aggregate, engine:engine, power:power,
         transmission:transmission, drive:drive, body_base:body_base, body_version:body_version)
    end

    def self.parse_new_key(key)
      brand, model_and_version, years, body, agregate = key.split(' ')
      model, version = model_and_version.split('.')
      # engine, power, transmission, drive = agregate.split('-')
      new(brand: brand, model: model, years: years, body: body, version: version, aggregate: aggregate)
    end
  end
end