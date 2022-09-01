class CreateDestinationAttrs < ActiveRecord::Migration[6.1]
  def change
    create_table :destination_attrs do |t|
      t.string :city_name
      t.string :country_name
      t.string :city_code

      t.timestamps
    end
  end
end
