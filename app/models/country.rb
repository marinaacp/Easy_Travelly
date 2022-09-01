class Country < ApplicationRecord
  has_many :destinations

  validates :code, uniqueness: true
end
