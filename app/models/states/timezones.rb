module States::Timezones
  PACIFIC = {"winter" => "UTC-08:00", "summer" => "UTC-07:00"}.freeze
  MOUNTAIN = {"winter" => "UTC-07:00", "summer" => "UTC-06:00"}.freeze
  MOUNTAIN_STANDARD = {"winter" => "UTC-07:00", "summer" => "UTC-07:00"}.freeze
  CENTRAL = {"winter" => "UTC-06:00", "summer" => "UTC-05:00"}.freeze
  EASTERN_STANDARD = {"winter" => "UTC-05:00", "summer" => "UTC-05:00"}.freeze
  CATALOGUE = {
    "Aguascalientes" => CENTRAL,
    "Baja California" => PACIFIC,
    "Baja California Sur" => MOUNTAIN,
    "Campeche" => CENTRAL,
    "CDMX" => CENTRAL,
    "Chiapas" => CENTRAL,
    "Chihuahua" => MOUNTAIN,
    "Coahuila" => CENTRAL,
    "Colima" => CENTRAL,
    "Durango" => CENTRAL,
    "Guanajuato" => CENTRAL,
    "Guerrero" => CENTRAL,
    "Hidalgo" => CENTRAL,
    "Jalisco" => CENTRAL,
    "México" => CENTRAL,
    "Michoacán" => CENTRAL,
    "Morelos" => CENTRAL,
    "Nayarit" => MOUNTAIN,
    "Nuevo León" => CENTRAL,
    "Oaxaca" => CENTRAL,
    "Puebla" => CENTRAL,
    "Querétaro" => CENTRAL,
    "Quintana Roo" => EASTERN_STANDARD,
    "San Luis Potosí" => CENTRAL,
    "Sinaloa" => MOUNTAIN,
    "Sonora" => MOUNTAIN_STANDARD,
    "Tabasco" => CENTRAL,
    "Tamaulipas" => CENTRAL,
    "Tlaxcala" => CENTRAL,
    "Veracruz" => CENTRAL,
    "Yucatán" => CENTRAL,
    "Zacatecas" => CENTRAL
  }.freeze
end
