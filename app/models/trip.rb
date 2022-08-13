class Trip < ApplicationRecord
  has_one :booking
  belongs_to :user

  geocoded_by :destination
  after_validation :geocode, if: :will_save_change_to_destination?
end
