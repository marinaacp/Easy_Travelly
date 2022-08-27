class AddReviewToHotels < ActiveRecord::Migration[6.1]
  def change
    add_column :hotels, :rate, :float
    add_column :hotels, :reviewCount, :integer
  end
end
