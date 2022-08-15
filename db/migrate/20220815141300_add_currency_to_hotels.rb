class AddCurrencyToHotels < ActiveRecord::Migration[6.1]
  def change
    add_column :hotels, :currency, :string
  end
end
