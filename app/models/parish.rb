class Parish < ApplicationRecord
  belongs_to :municipality

  has_many :masses
end
