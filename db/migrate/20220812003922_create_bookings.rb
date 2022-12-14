class CreateBookings < ActiveRecord::Migration[6.1]
  def change
    create_table :bookings do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :hotel, null: false, foreign_key: true
      t.references :flight, null: false, foreign_key: true

      t.timestamps
    end
  end
end
