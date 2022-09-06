class RemoveMoreDetailsFromFlights < ActiveRecord::Migration[6.1]
  def change
    remove_column :flights, :departure_departure, :date
    remove_column :flights, :departure_arrival, :date
    remove_column :flights, :return_departure, :date
    remove_column :flights, :return_arrival, :date
  end
end
