class CreateParishes < ActiveRecord::Migration[7.0]
  def change
    create_table :parishes do |t|
      t.string :name, null: false
      t.references :municipality, null: false, foreign_key: true
      t.string :address

      t.timestamps
    end
  end
end
