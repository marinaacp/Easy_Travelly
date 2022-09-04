class Activity < ApplicationRecord
  belongs_to :trip

  validates :name, uniqueness: { scope: :trip }, length: { maximum: 65 }
end
