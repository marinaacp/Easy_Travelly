class AddNameToTrips < ActiveRecord::Migration[6.1]
  def change
    add_column :trips, :name, :string
  end
end
