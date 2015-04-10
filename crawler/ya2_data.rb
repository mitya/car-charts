module CWD
  module_function

  def access_property(name)
    @properties ||= {}
    @properties[name] ||= yield
  end
  
  def property(name, &block)
    singleton_class.send :define_method, name do
      access_property(name, &block)
    end
  end
  

  property :bodytypes_by_title do
    YAML.load_file("crawler/data-bodies.yml").invert
  end

  property :bodytype_default_titles_pattern do
    Regexp.new(bodytypes_by_title.keys.join('|'))
  end

  property :used_fields do
    YAML.load_file("crawler/data-parameters.yml")['field_keys']
  end

  property :data_translations do
    translations = YAML.load_file("crawler/data-translations.yml")
    translations['values'].each_with_object({}) { |(k, hash), results| results[k] = hash.invert }
  end

  property :model_classification do
    YAML.load_file("crawler/data-classification.yml")
  end

  def translations(field, title)
    data_translations[field.to_s][title]
  end

  property :yandex_brand_names do
    data_brands['brands']
  end
  
  property :adjusted_brand_names do
    data_brands['brands'].dup.update data_brands['brands_overrides']
  end

  property :yandex_short_brand_names do
    data_brands['brands'].dup.update data_brands['short_yandex_brands']
  end
  
  property :data_brands do
    YAML.load_file("crawler/data-brands.yml")
  end
  
  property :data_reductions do
    YAML.load_file("crawler/data-reductions.yml")
  end  
end

Info = CWD

Rus_Months = %w(Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь)
