module CWD
  Reductions_Body_Body = {
    [:audi, 'хэтчбек 5 дв. Sportback'] => 'хэтчбек 5 дв.',
    [:mercedes, 'универсал Shooting Brake'] => 'универсал',
    [:mercedes, 'седан AMG'] => 'седан',
    [:mercedes, 'седан AMG Long'] => 'седан Long',
    [:mercedes, 'кабриолет AMG'] => 'кабриолет',
    [:mercedes, 'купе AMG'] => 'купе',
    [:hyundai, 'седан Limusine'] => 'седан Long',
    [:land_rover, 'внедорожник 3 дв. 90'] => 'внедорожник 3 дв.',
    [:land_rover, 'внедорожник 5 дв. 110'] => 'внедорожник 5 дв.',
    [:opel, 'хэтчбек 3 дв. GTC'] => 'хэтчбек 3 дв.',
    [:opel, 'универсал Sports Tourer'] => 'универсал',
    [:kia, 'хэтчбек 3 дв. pro_cee\'d'] => 'хэтчбек 3 дв.',
    [:vaz, 'внедорожник 2121'] => 'внедорожник 3 дв.',
    [:vaz, 'внедорожник 2131'] => 'внедорожник 5 дв.',
    [:volkswagen, 'пикап 2 дв. Single Cab'] => 'пикап 2 дв.',
    [:volkswagen, 'пикап 4 дв. Double Cab'] => 'пикап 4 дв.',
    [:volvo, 'универсал Plug-in-Hybrid'] => 'универсал',
  }
  
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
end
