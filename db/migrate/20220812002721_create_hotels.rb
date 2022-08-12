class CreateHotels < ActiveRecord::Migration[6.1]
  def change
    create_table :hotels do |t|
      t.string :name
      t.date :check_in
      t.date :check_out
      t.float :price
      t.references :trip, null: false, foreign_key: true

      t.timestamps
    end
  end
end
