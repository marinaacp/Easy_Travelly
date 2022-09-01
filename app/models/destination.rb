class Destination < ApplicationRecord
  belongs_to :country
  validates :code, uniqueness: true
end
