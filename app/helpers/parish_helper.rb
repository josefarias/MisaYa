module ParishHelper
  def mass_has_happened?(municipality, mass_time)
    now = Time.current.in_time_zone(municipality.timezone)
    hour, min, period = mass_time.match(/(\d{2}):(\d{2}) (\w{2})/).captures
    hour = hour.to_i + 12 if period == "PM" && hour != "12"
    now.change(hour: hour, min: min).before?(now)
  end
end
