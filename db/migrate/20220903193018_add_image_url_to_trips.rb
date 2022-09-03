class AddImageUrlToTrips < ActiveRecord::Migration[6.1]
  def change
    add_column :trips, :image_url, :string
  end
end
