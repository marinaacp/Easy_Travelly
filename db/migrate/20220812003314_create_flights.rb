class CreateFlights < ActiveRecord::Migration[6.1]
  def change
    create_table :flights do |t|
      t.date :departure
      t.float :price
      t.references :trip, null: false, foreign_key: true

      t.timestamps
    end
  end
end
