class Municipality < ApplicationRecord
  belongs_to :state

  has_many :parishes
end
