class AddCategoryAndZoneNameToHotels < ActiveRecord::Migration[6.1]
  def change
    add_column :hotels, :category, :string
    add_column :hotels, :zone_name, :string
  end
end
