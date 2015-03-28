# loader & source parcer constants

# BASE_BODY_TYPES= {
#   "седан"       => "sedan",
#   "универсал"   => "wagon",
#   "хэтчбек"     => "hatch",
#   "купе"        => "coupe",
#   "кабриолет"   => "cabrio",
#   "кроссовер"   => "crossover",
#   "вседорожник" => "SUV",
#   "минивэн"     => "minivan",
#   "пикап"       => "pickup",
#   "фургон"      => "van"
# }
#
# BASE_BODY_TYPES_RE = Regexp.new(BASE_BODY_TYPES.keys.join('|'))
#
# BODY_TYPES = {
#   "пикап"            => "pickup",
#   "фургон"           => "van",
#   "вседорожник 3 дв" => "suv_3d",
#   "вседорожник 5 дв" => "suv_5d",
#   "кабриолет"        => "cabrio",
#   "кроссовер"        => "crossover",
#   "купе"             => "coupe",
#   "хэтчбек 3 дв"     => "hatch_3d",
#   "минивэн"          => "minivan",
#   "универсал"        => "wagon",
#   "вседорожник"      => "suv",
#   "хэтчбек 5 дв"     => "hatch_5d",
#   "седан"            => "sedan"
#
# }
#
# VENDORS_TRANSLIT = {
#   "LADA (ВАЗ)"    => "VAZ",
#   "УАЗ"           => "UAZ",
#   "ГАЗ"           => "GAZ",
#   "Mercedes-Benz" => "Mercedes"
# }
#
# MODEL_ENGLISH_TITLE_FIXES = {
#   "Audi A6 Allroad quattro"    => "A6 allroad quattro",
#   "BMW 1 серия М"              => "1 M",
#   "LADA (ВАЗ) Надежда"         => "Nadezhda",
#   "LADA (ВАЗ) Нива 4х4 (2121)" => "2121 Niva",
#   "LADA (ВАЗ) Нива 4х4 (2131)" => "2131 Niva",
#   "LADA (ВАЗ) Ока"             => "Oka",
#   "ГАЗ 31105 Волга"            => "31105 Volga",
#   "Chrysler 300С"              => "300C",
#   "Chrysler 300М"              => "300M",
# }
#
# # common constants
#
Keys_All = %w(
  model_key version_key body
  transmission drive gears displacement displacement_key fuel fuel_rating compressor top_speed  acceleration_100kmh engine_layout
  max_power max_power_kw max_torque max_power_range_start max_power_range_end max_torque_range_start max_torque_range_end
  bore stroke compression cylinder_placement injection cylinder_valves cylinder_count consumption_city consumption_highway consumption_mixed
  length width height ground_clearance wheelbase front_tire_rut rear_tire_rut kerbweight gross_mass luggage_min luggage_max seats_min seats_max doors
  tank_capacity tires produced_since produced_till countries
  front_brakes rear_brakes front_suspension rear_suspension price).uniq
Keys_Rejected = %w(front_suspension rear_suspension front_brakes rear_brakes price)
Keys_Used = (Keys_All - Keys_Rejected).map(&:to_sym).uniq
#
# Translations_Vendors = {
#   "Acura"         => "acura",
#   "Alfa Romeo"    => "alfa_romeo",
#   "Audi"          => "audi",
#   "BMW"           => "bmw",
#   "Cadillac"      => "cadillac",
#   "Chery"         => "chery",
#   "Chevrolet"     => "chevrolet",
#   "Chrysler"      => "chrysler",
#   "Citroen"       => "citroen",
#   "Daewoo"        => "daewoo",
#   "Dodge"         => "dodge",
#   "FIAT"          => "fiat",
#   "Ford"          => "ford",
#   "Great Wall"    => "great_wall",
#   "Honda"         => "honda",
#   "Hummer"        => "hummer",
#   "Hyundai"       => "hyundai",
#   "Infiniti"      => "infiniti",
#   "Jaguar"        => "jaguar",
#   "Jeep"          => "jeep",
#   "Kia"           => "kia",
#   "Land Rover"    => "land_rover",
#   "Lexus"         => "lexus",
#   "MINI"          => "mini",
#   "Mazda"         => "mazda",
#   "Mercedes-Benz" => "mercedes_benz",
#   "Mitsubishi"    => "mitsubishi",
#   "Nissan"        => "nissan",
#   "Opel"          => "opel",
#   "Peugeot"       => "peugeot",
#   "Porsche"       => "porsche",
#   "Renault"       => "renault",
#   "SEAT"          => "seat",
#   "Saab"          => "saab",
#   "Skoda"         => "skoda",
#   "SsangYong"     => "ssangyong",
#   "Subaru"        => "subaru",
#   "Suzuki"        => "suzuki",
#   "Toyota"        => "toyota",
#   "Volkswagen"    => "volkswagen",
#   "Volvo"         => "volvo",
#   "LADA (ВАЗ)"    => "vaz",
#   "ВАЗ"           => "vaz",
#   "ВАЗ (LADA)"    => "vaz",
#   "ГАЗ"           => "gaz",
#   "УАЗ"           => "uaz"
# }




# Translations_Values_Suspensions = {
#   "зависимая, пневмоэлемент" => 20501, # :dependent_pneumo,
#   "зависимая, пружинная" => 20502, # :dependent_coil,
#   "зависимая, рессорная" => 20503, # :dependent_spring,
#   "полунезависимая, торсионная" => 20504, # :semidependent_torsion,
#   "полунезависимая, пружинная" => 20505, # :semidependent_coil,
#   "независимая, рессорная" => 20506, # :independent_spring,
#   "независимая, гидропневмоэлемент" => 20507, # :independent_hydro_pneumo,
#   "независимая, торсионная" => 20508, # :independent_torsion,
#   "независимая, пневмоэлемент" => 20509, # :independent_pneumo,
#   "независимая, пружинная" => 20510, # :independent_coil
# }
#
# Translations_Values_Brakes = {
#  "керамические вентилируемые" => 20401, # :ceramic_ventilated,
#  "дисковые барабанные" => 20402, # :disc_or_drum,
#  "барабанные  дисковые" => 20403, # :disc_or_drum,
#  "барабанные" => 20404, # :drum,
#  "дисковые вентилируемые" => 20405, # :disc_ventilated,
#  "дисковые" => 20406, # :disc
# }
#
# Translations_Values_Drives = { "полный" => "4WD", "передний" => "FWD", "задний" => "RWD" }
#
# Translations_Values_FuelSigns = { "бензин" => "i", "дизель" => "d" }
#
# Translations_Values = {
#   cylinder_placement: {
#     "W-образное" => :W,
#     "роторный двигатель" => :R,
#     "V-образное с малым углом развала цилиндров" => :V,
#     "оппозитное" => :F,
#     "V-образное" => :V,
#     "рядное" => :I
#   },
#   engine_layout: {
#     "центральное" => 20101, # :mid,
#     "заднее" => 20102, # :rear,
#     "переднее, продольное" => 20103, # :front_longitudinally,
#     "переднее, поперечное" => 20104, # :front_transversely,
#   },
#   injection: {
#     "центральный впрыск" => 20201, # :central_injection,
#     "двигатель с разделенными камерами сгорания (вихрекамерный или предкамерный)" => 20202, # :separated_combustor,
#     "карбюратор" => 20203, # :carburetor,
#     "двигатель с неразделенными камерами сгорания (непосредственный впрыск топлива)" => 20204, # :nonseparated_combustor,
#     "непосредственный впрыск в камеру сгорания" => 20205, # :direct_injection,
#     "распределенный впрыск" => 20206, # :distributed_injection,
#   },
#   compressor: {
#     "объемный нагнетатель с механическим приводом" => 20301, # :supercharger,
#     "турбонаддув" => 20302, # :turbo,
#     "турбонаддув с промежуточным охлаждением воздуха" => 20303, # :turbo_intercooler,
#     "нет" => nil
#   },
#   front_suspension: Translations_Values_Suspensions,
#   rear_suspension:  Translations_Values_Suspensions,
#   front_brakes:     Translations_Values_Brakes,
#   rear_brakes:      Translations_Values_Brakes,
#
#   drive:            {"передний" => :FWD, "задний" => :RWD, "полный" => :AWD},
#   fuel:             {"бензин" => :P, "дизель" => :D, "гибрид" => :H},
#   fuel_rating:      {"АИ-76" => :A76, "АИ-92" => :A92, "АИ-95" => :A95, "АИ-98" => :A98, "ДТ" => :DT},
#   transmission:     {"механическая" => :MT, "автомат" => :AT, "вариатор" => :CVT, "роботизированная" => :AMT}
# }


# # Mapping_Body = {
# #   sedan:        :SE,
# #   sedan_long:   :SEL,
# #   hatch_3d:     :HT3,
# #   hatch_5d:     :HT5,
# #   wagon:        :WG,
# #   minivan:      :MV,
# #   minivan_3d:   :MV3,
# #   crossover:    :CX,
# #   crossover_3d: :CX3,
# #   crossover_5d: :CX5,
# #   suv:          :SUV,
# #   suv_2d:       :SUV2,
# #   suv_3d:       :SUV3,
# #   suv_4d:       :SUV4,
# #   suv_5d:       :SUV5,
# #   coupe:        :COP,
# #   coupe_2d:     :COP2,
# #   coupe_5d:     :COP5,
# #   cabrio:       :CBR,
# #   pickup:       :PK,
# #   pickup_2d:    :PK2,
# #   pickup_4d:    :PK4,
# #   van:          :VAN,
# #   minivan_5d_partner_tepee: :MV5
# # }
#
#



# Attributes_Vendor_Name = Translations_Vendors.invert
#
# Attributes_Model_Name = {
#   "land_rover--range_rover"        => "Range Rover",
#   "land_rover--range_rover_evoque" => "Range Rover Evoque",
#   "land_rover--range_rover_sport"  => "Range Rover Sport",
# }
#
# Attributes_Model_BrandedName = {
#   "land_rover--range_rover"        => "Range Rover",
#   "land_rover--range_rover_evoque" => "Range Rover Evoque",
#   "land_rover--range_rover_sport"  => "Range Rover Sport",
# }


Rus_Months = %w(Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь)
