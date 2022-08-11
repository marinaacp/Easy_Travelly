class CreateFlights < ActiveRecord::Migration[6.1]
  def change
    create_table :flights do |t|
      t.string :location
      t.string :destination
      t.date :departure
      t.float :price

      t.timestamps
    end
  end
end
