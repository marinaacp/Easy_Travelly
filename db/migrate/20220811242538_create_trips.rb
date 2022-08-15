class CreateTrips < ActiveRecord::Migration[6.1]
  def change
    create_table :trips do |t|
      t.string :location
      t.string :destination
      t.date :start_date
      t.date :end_date
      t.integer :travellers
      t.float :budget
      t.integer :pflight, default: 30
      t.integer :photel, default: 40

      t.timestamps
    end
  end
end
