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
end
