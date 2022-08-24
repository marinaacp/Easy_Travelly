class CreateFlights < ActiveRecord::Migration[6.1]
  def change
    create_table :flights do |t|
      t.string :reservation_number
      # ida
      t.date :departure_departure
      t.string :airport_departure_departure
      t.date :departure_arrivel
      t.string :airport_departure_arrival
      # volta
      t.date :return_departure
      t.string :airport_return_departure
      t.date :return_arrivel
      t.string :airport_return_arrival

      t.float :price
      t.string :currency
      t.references :trip, null: false, foreign_key: true

      t.timestamps
    end
  end
end
