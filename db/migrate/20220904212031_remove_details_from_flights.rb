class RemoveDetailsFromFlights < ActiveRecord::Migration[6.1]
  def change
    remove_column :flights, :aircraft_departure_airline, :string
    remove_column :flights, :terminal_departure_departure, :integer
    remove_column :flights, :terminal_departure_arrival, :integer
    remove_column :flights, :aircraft_return_airline, :string
    remove_column :flights, :terminal_return_departure, :integer
    remove_column :flights, :terminal_return_arrival, :integer
  end
end
