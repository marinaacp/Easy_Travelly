class AddCountryCodeToDestinationAttr < ActiveRecord::Migration[6.1]
  def change
    add_column :destination_attrs, :country_code, :string
  end
end
