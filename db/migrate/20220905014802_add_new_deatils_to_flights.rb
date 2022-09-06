class AddNewDeatilsToFlights < ActiveRecord::Migration[6.1]
  def change
    add_column :flights, :departure_departure, :string
    add_column :flights, :departure_arrival, :string
    add_column :flights, :return_departure, :string
    add_column :flights, :return_arrival, :string
  end
end
