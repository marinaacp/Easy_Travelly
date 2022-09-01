class AddCurrencyToTrips < ActiveRecord::Migration[6.1]
  def change
    add_column :trips, :budgetCurrency, :string
  end
end
