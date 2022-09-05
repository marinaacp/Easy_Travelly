class AddKindsToActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :kinds, :text, array: true
    remove_column :activities, :kind
  end
end
