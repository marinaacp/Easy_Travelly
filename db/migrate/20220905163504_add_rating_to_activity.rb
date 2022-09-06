class AddRatingToActivity < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :rating, :string
  end
end
