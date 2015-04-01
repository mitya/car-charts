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

  property :used_fields do
    YAML.load_file("crawler/data-other.yml")['field_keys']
  end

  property :data_translations do
    translations = YAML.load_file("crawler/data-translations.yml")
    translations['values'].each_with_object({}) { |(k, hash), results| results[k] = hash.invert }
  end

  property :model_classification do
    YAML.load_file("crawler/data-classification.yml")
  end

  property :translations do |field, title|
    data_translations[field.to_s][title]
  end

  property :yandex_brand_names do
    data_brands['brands']
  end
  
  property :adjusted_brand_names do
    data_brands['brands'].dup.update data_brands['brands_overrides']
  end
  
  property :data_brands do
    YAML.load_file("crawler/data-brands.yml")
  end
end
