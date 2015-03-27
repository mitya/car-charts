# Parses mods pages
# 
# Оценка безопасности не распарсена так как она не представлена в текстовом виде
# 
class YA2Parser
  def step_8_1__html_to_hashes
    results = {}
    CW.parse_dir("07-mods-stripped") do |doc, basename, path|
      result = results[basename] = {}
      doc.css(".b-specifications__details .b-features__item_type_specs").each do |div|
        name = div.at_css(".b-features__name").text
        name_translation = Translations_Parameters[name.strip]
        value = div.at_css(".b-features__value").text.strip

        puts "TRANSLATION MISSING: #{name}" unless name_translation
        result[name_translation.to_s] = value
      end      
    end
    CW.write_data "08.1-mods", results
  end


  # def classification
  #   ModelClassification.each { |k,v| ModelClassification[k] = nil if v == '' }
  #   CW.write_data "classification", ModelClassification
  # end
end
