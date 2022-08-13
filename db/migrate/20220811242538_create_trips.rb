class CreateTrips < ActiveRecord::Migration[6.1]
  def change
    create_table :trips do |t|
      t.string :location
      t.string :destination
      t.date :start_date
      t.date :end_date
      t.integer :travellers
      t.float :budget
      t.integer :pflight
      t.integer :photel

      t.timestamps
    end
  end
end
