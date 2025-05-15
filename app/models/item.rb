class Item < ApplicationRecord
  enum item_type: { rental: 0, sale: 1 }

  validates :name, :item_type, :price, presence: true

  has_many :reservation_items
  has_many :reservations, through: :reservation_items
end
