require "demo_data"

namespace :demo do
  task create: :environment do
    DEMO_STATES.each do |state|
      db_state = State.create(name: state[:name])

      state[:municipalities].each do |municipality|
        db_municipality = db_state.municipalities.create(name: municipality[:name])

        municipality[:parishes].each do |parish|
          db_parish = db_municipality.parishes.create(name: parish[:name], address: parish[:address])

          db_parish.masses.insert_all(parish[:masses]) if parish[:masses].present?
        end
      end
    end
  end
end
