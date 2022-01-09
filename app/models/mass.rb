class Mass < ApplicationRecord
  belongs_to :parish
  has_one :municipality, through: :parish

  enum day: {sunday: 0, monday: 1, tuesday: 2,
             wednesday: 3, thursday: 4, friday: 5, saturday: 6}
  enum kind: {charismatic: 0, daily: 1, dominical: 2,
              kid_friendly: 3, young_adult: 4, in_latin: 5}

  scope :for_day, ->(day) do
    where(day: day)
  end

  def parsed_time
    @parsed_time ||= begin
      time_regex = /(\d{2}):(\d{2}) (\w{2})/
      hour, minute, period = time.match(time_regex).captures
      hour, minute = [hour, minute].map(&:to_i)

      hour += 12 if period == "PM" && hour != 12

      {hour:, minute:}
    end
  end

  def happened_today?
    now = Time.current.in_time_zone(municipality.timezone)
    return false unless now.wday == day_before_type_cast
    now.change(hour: parsed_time[:hour], min: parsed_time[:minute]).before?(now)
  end
end
