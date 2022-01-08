# frozen_string_literal: true

class Municipality < ApplicationRecord
  belongs_to :state

  has_many :parishes

  def timezone
    path = Rails.root.join(TIMEZONES_FILE_PATH)
    file = File.read(path)
    yaml = Psych.safe_load(file)

    yaml["municipalities"][name.parameterize.underscore] ||
      yaml["states"][state.name.parameterize.underscore]
  end

  private

  TIMEZONES_FILE_PATH = "config/timezones.yml"
end
