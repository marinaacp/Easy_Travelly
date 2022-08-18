class AddRoomsAndChildrenToTrips < ActiveRecord::Migration[6.1]
  def change
    add_column :trips, :rooms, :integer
    add_column :trips, :children, :integer
    rename_column :trips, :travellers, :adults
  end
end
