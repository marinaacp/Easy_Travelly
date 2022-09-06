class RemoveFlightClassFromTrips < ActiveRecord::Migration[6.1]
  def change
    remove_column :trips, :flight_class, :string
  end
end
