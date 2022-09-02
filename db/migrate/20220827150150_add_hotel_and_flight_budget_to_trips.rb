class AddHotelAndFlightBudgetToTrips < ActiveRecord::Migration[6.1]
  def change
    add_column :trips, :budgetHotel, :float
    add_column :trips, :budgetFlight, :float
  end
end
