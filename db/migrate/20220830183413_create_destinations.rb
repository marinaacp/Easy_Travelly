class CreateDestinations < ActiveRecord::Migration[6.1]
  def change
    create_table :destinations do |t|
      t.string :code
      t.string :name
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
