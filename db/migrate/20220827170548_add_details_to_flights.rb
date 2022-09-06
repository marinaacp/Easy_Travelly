class AddDetailsToFlights < ActiveRecord::Migration[6.1]
  def change
    add_column :flights, :emissions, :integer
    add_column :flights, :departure_start_time, :datetime
    add_column :flights, :departure_end_time, :datetime
    add_column :flights, :departure_class, :string
    add_column :flights, :departure_baggage, :integer
    add_column :flights, :logo_departure_airline, :string
    add_column :flights, :aircraft_departure_airline, :string
    add_column :flights, :terminal_departure_departure, :integer
    add_column :flights, :terminal_departure_arrival, :integer
    add_column :flights, :return_start_time, :datetime
    add_column :flights, :return_end_time, :datetime
    add_column :flights, :return_class, :string
    add_column :flights, :return_baggage, :integer
    add_column :flights, :logo_return_airline, :string
    add_column :flights, :aircraft_return_airline, :string
    add_column :flights, :terminal_return_departure, :integer
    add_column :flights, :terminal_return_arrival, :integer
  end
end
