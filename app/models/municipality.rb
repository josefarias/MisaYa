class Municipality < ApplicationRecord
  belongs_to :state

  has_many :parishes

  def timezone
    file = File.read(TIMEZONES_FILE_PATH)
    yaml = Psych.safe_load(file)

    yaml["municipalities"][name.parameterize.underscore] ||
      yaml["states"][state.name.parameterize.underscore]
  end

  private

  TIMEZONES_FILE_PATH = Rails.root.join("config/timezones.yml")
end
