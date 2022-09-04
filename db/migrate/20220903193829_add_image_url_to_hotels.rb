class AddImageUrlToHotels < ActiveRecord::Migration[6.1]
  def change
    add_column :hotels, :image_url, :string
  end
end
