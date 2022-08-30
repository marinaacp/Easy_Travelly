class RemoveChildrenFromTrips < ActiveRecord::Migration[6.1]
  def change
    remove_column :trips, :children
  end
end
