class CreateMasses < ActiveRecord::Migration[7.0]
  def change
    create_table :masses do |t|
      t.references :parish, null: false, foreign_key: true
      t.integer :kind
      t.integer :day, null: false
      t.time :time, null: false

      t.timestamps
    end
  end
end
