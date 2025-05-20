class Item < ApplicationRecord
  enum item_type: { rental: 0, sale: 1 }

  validates :name, :item_type, :price, presence: true
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_many :reservation_items, dependent: :destroy
  has_many :reservations, through: :reservation_items
end
