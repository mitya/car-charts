module CWD
  Reductions_Body_Model = {
    ['volkswagen passat 2011', 'универсал Alltrack'] => 'volkswagen passat_alltrack 2011 wagon'
    # stepway
  }
  
  DisabledBodies = %w(микроавтобус фургон)

  Bodies = {
    "седан"             => :sedan,
    "седан Long"        => :sedan_long,
    "универсал"         => :wagon,
    "хэтчбек 3 дв."     => :hatch_3d,
    "хэтчбек 4 дв."     => :hatch_4d,
    "хэтчбек 5 дв."     => :hatch_5d,
    "купе"              => :coupe,
    "кабриолет"         => :cabrio,
    "кроссовер"         => :crossover,
    "кроссовер 3 дв."   => :crossover_3d,
    "кроссовер 5 дв."   => :crossover_5d,
    "вседорожник"       => :suv,
    "вседорожник 3 дв." => :suv_3d,
    "вседорожник 4 дв." => :suv_4d,
    "вседорожник 5 дв." => :suv_5d,
    "вседорожник Long"  => :suv_long,
    "внедорожник"       => :suv,
    "внедорожник 3 дв." => :suv_3d,
    "внедорожник 5 дв." => :suv_5d,
    "минивен"           => :minivan,
    "минивен Long"      => :minivan_long,
    "пикап"             => :pickup,
    "пикап 2 дв."       => :pickup_2d,
    "пикап 4 дв."       => :pickup_4d,
                            
    "микроавтобус"      => :minibus,
    "фургон"            => :van,
  }  
  
  Translations_Values = {
    drive: {"передний" => :FWD, "задний" => :RWD, "полный" => :AWD},
    fuel: {"бензин" => :i, "дизель" => :d, "гибрид" => :h, "газ / бензин" => :g},
    fuel_rating: {"АИ-76" => :A76, "АИ-92" => :A92, "АИ-95" => :A95, "АИ-98" => :A98, "ДТ" => :DT},
    transmission: {"механическая" => :MT, "автомат" => :AT, "вариатор" => :CVT, "роботизированная" => :AMT}
  }
  
  
  
  def self.used_fields
    @data_other ||= YAML.load_file("crawler/data-other.yml")
    @data_other['field_keys']
  end
  
  def self.model_classification
    @model_classification = YAML.load_file("crawler/data-classification.yml")
  end
  
  def self.translations(field, title)
    data_translations[field.to_s][title]
  end
  
  def self.data_translations
    @data_translations_original ||= YAML.load_file("crawler/data-translations.yml")
    @data_translations_inverted ||= begin
      @data_translations_inverted = {}
      @data_translations_original['values'].each do |k, hash|
        @data_translations_inverted[k] = hash.invert
      end
      @data_translations_inverted
    end
  end
end
