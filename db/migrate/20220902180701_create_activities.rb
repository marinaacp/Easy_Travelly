class CreateActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :activities do |t|
      t.string :kind
      t.string :name
      t.string :link
      t.string :image
      t.references :trip, null: false, foreign_key: true

      t.timestamps
    end
  end
end
