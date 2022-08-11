class CreateHotels < ActiveRecord::Migration[6.1]
  def change
    create_table :hotels do |t|
      t.string :location
      t.date :check_in
      t.date :check_out
      t.float :price
      t.integer :rating

      t.timestamps
    end
  end
end
