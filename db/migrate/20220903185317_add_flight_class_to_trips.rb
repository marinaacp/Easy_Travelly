class AddFlightClassToTrips < ActiveRecord::Migration[6.1]
  def change
    add_column :trips, :flight_class, :string
  end
end
